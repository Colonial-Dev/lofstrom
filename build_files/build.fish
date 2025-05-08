#!/usr/bin/env fish

set -gx fish_trace on

function trap -a command
    function $command -V command
        command $command $argv
        
        set -l s $status

        if [ $s -ne 0 ]
            exit $s
        else
            return 0
        end
    end
end

trap dnf5 rpm

# Copy OS files into image root
rsync -rvK /ctx/os_files/ /

# Make root's $HOME
mkdir -p /var/roothome

# Install DNF5
rpm-ostree install dnf5 dnf5-plugins

# Enable RPMFusion
dnf5 install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 install -y rpmfusion-\*-appstream-data

# Enable Visual Studio Code
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e \
    "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" \
    | tee /etc/yum.repos.d/vscode.repo > /dev/null

# Refresh repository data
dnf5 update -y

# Enable Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Power-up FFmpeg and other codecs/drivers
dnf5 swap -y ffmpeg-free ffmpeg --allowerasing

dnf5 group install -y multimedia \
    --setopt="install_weak_deps=False" \
    --exclude=PackageKit-gstreamer-plugin

dnf5 group install -y sound-and-video

# -> Intel drivers
dnf5 install -y intel-media-driver libva-intel-driver

# -> AMD drivers
dnf5 swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf5 swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

# Install and remove requested/excluded packages
set -l RPM_ADD (jq -r '.rpm.add[]' /ctx/packages.json)
set -l RPM_DEL (jq -r '.rpm.del[]' /ctx/packages.json)

if [ (count $RPM_ADD) != 0 ]
    dnf5 -y install $RPM_ADD
end

if [ (count $RPM_DEL) != 0 ]
    dnf5 -y remove $RPM_DEL
end

set -l FLATPAK_ADD (jq -r '.flatpak.add[]' /ctx/packages.json)
set -l FLATPAK_DEL (jq -r '.flatpak.del[]' /ctx/packages.json)

if [ (count $FLATPAK_ADD) != 0 ]
    flatpak --noninteractive install flathub $FLATPAK_ADD
end

if [ (count $FLATPAK_DEL) != 0 ]
    flatpak --noninteractive uninstall $FLATPAK_DEL
end

# -> Install Box
curl \
    --proto '=https' --tlsv1.2 \
    -Lo /usr/bin/box \
    https://github.com/Colonial-Dev/box/releases/latest/download/bx-x86_64-unknown-linux-musl

chmod 0755 /usr/bin/box

# Other modifications

# -> Enable automatic update timers
systemctl enable rpm-ostreed-automatic.timer
systemctl enable flatpak-system-update.timer
systemctl --global enable flatpak-user-update.timer

# -> Enable automatic Podman container restarts
systemctl enable podman-restart.service
systemctl --global enable podman-restart.service

# Cleanup
# -> Clear DNF caches
dnf5 clean all

# -> Remove DNF (useless in an atomic deployment)
dnf5 remove -y \
    --setopt=protected_packages= \
    dnf5 dnf5-plugins

# -> Cleanup caches and other directories that bootc doesn't like
bash -c "
    rm -rf /tmp/* || true
    rm -rf /usr/etc
    rm -rf /boot && mkdir /boot
    shopt -s extglob
    rm -rf /var/!(cache)
    rm -rf /var/cache/!(libdnf5)      
"

# -> Remove Syncthing GUI icons
rm /usr/share/applications/syncthing*