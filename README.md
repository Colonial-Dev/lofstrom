<h1 align="center">Lofstrom</h1>
<h3 align="center">A batteries-included Fedora Silverblue spin.</h3>

<p align="center">
<img src="https://img.shields.io/github/actions/workflow/status/Colonial-Dev/lofstrom/build.yml">
<img src="https://img.shields.io/github/license/Colonial-Dev/lofstrom">
<img src="https://img.shields.io/github/stars/Colonial-Dev/lofstrom">
</p>

Lofstrom[^1] is my take on a batteries-included Fedora Silverblue.

Unlike vanilla Silverblue, Lofstrom includes:
- A full suite of media codecs and drivers, free *and* non-free.
- RPMFusion repositories.
- Various favored tools:
  - Network (`traceroute`, `nmap`...)
  - Terminal (`wl-clipboard`, `fzf`, `rg`, `units`...)
  - [GNOME Extension Manager](https://flathub.org/apps/com.mattjakeman.ExtensionManager), [Refine](https://flathub.org/apps/page.tesk.Refine), and [Flatseal](https://flathub.org/apps/com.github.tchx84.Flatseal).
  - Visual Studio Code.

Lofstrom also removes GNOME Tour, Extensions, Connections, Fedora Media Writer, and Parental Controls.

Although this repository is derived from the template provided by Universal Blue, Lofstrom is built directly on top of vanilla Silverblue - *not* a more opinionated spin like Bazzite. My goal is to create a "drop in" improvement for the generally excellent 
experience offered by vanilla Silverblue, with a minimum of added depedencies and third parties[^2].

[^1]: Named for the [Lofstrom launch loop](https://toughsf.blogspot.com/2023/12/the-loftstrom-loop-bridge-to-space.html) concept.
[^2]: The Universal Blue base images pulling in a COPR for [racing simulator wheels](https://github.com/ublue-os/main/blob/6b6be9feca43fee984cb742c18f66664e53c58da/build_files/install.sh#L24) is a bit excessive for my taste. <br> Lofstrom, by contrast, only adds dependencies on RPMFusion, Visual Studio Code and (technically) yours truly.