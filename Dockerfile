FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    ninja \
    cmake \
    python \
    zlib \
    libxml2 \
    ncurses \
    libedit

CMD ["/bin/bash"]
