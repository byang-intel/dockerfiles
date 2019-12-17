FROM ubuntu:18.04 AS builder

#COPY sources.list /etc/apt/sources.list

ENV LC_CTYPE="en_US.UTF-8" LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8" LANGUAGE="en_US:en" \
    DISPLAY=:0 \
    DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list \
    && apt-get -y update \
    && apt-get install -y \
        software-properties-common \
    && add-apt-repository ppa:strukturag/libheif \
    && apt-get install -y \
        locales ca-certificates wget curl vim git \
        libheif-dev libheif-examples \
    && locale-gen en_US.UTF-8 \
    && update-ca-certificates \
    && apt-get build-dep -y imagemagick

RUN mkdir /opt/imagemagick \
    && wget --no-check-certificate -O- https://github.com/ImageMagick/ImageMagick/archive/7.0.9-8.tar.gz | tar -xzf - -C /opt/imagemagick --strip-components=1 \
    && cd /opt/imagemagick \
    && ./configure --prefix=/usr \
    && make -j$(nproc) \
    && make install DESTDIR=/opt/install_root

FROM ubuntu:18.04

#COPY sources.list /etc/apt/sources.list

ARG USER_NAME=byang
ARG USER_ID=1000
ARG USER_GID=1000

ENV LC_CTYPE="en_US.UTF-8" LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8" LANGUAGE="en_US:en" \
    DISPLAY=:0 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update \
    && apt-get install -y \
        software-properties-common \
    && add-apt-repository ppa:strukturag/libheif \
    && apt-get install -y \
        locales ca-certificates sudo openssh-client wget curl vim git rsync \
        ffmpeg libheif-dev libheif-examples webp \
	imagemagick \
    && locale-gen en_US.UTF-8 \
    && update-ca-certificates \
    && groupadd -o -g $USER_GID $USER_NAME \
    && useradd -Nmo -g $USER_GID -u $USER_ID $USER_NAME \
    && echo 'Defaults env_keep += "HTTP_PROXY HTTPS_PROXY NO_PROXY http_proxy https_proxy no_proxy"' >> /etc/sudoers \
    && echo "$USER_NAME ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && apt-get clean -y \
    && rm -rf \
        /var/cache/debconf/* \
        /var/lib/apt/lists/* \
        /var/log/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/doc/* \
        /usr/share/man/* \
        /usr/share/local/*

COPY --from=builder /opt/install_root /

USER $USER_NAME
