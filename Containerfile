# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY /os_files /os_files

# Base Image
FROM quay.io/fedora/fedora-silverblue:42

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/setup.sh && \
    ostree container commit
    
# Verify final image and contents are correct.
RUN bootc container lint
RUN ostree container commit