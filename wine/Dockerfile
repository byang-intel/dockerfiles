FROM byangintel/desktop-xfce4:1.00

#COPY sources.list /etc/apt/sources.list

ARG USER_NAME=byang
ARG USER_ID=1000
ARG USER_GID=1000

RUN apt-get -y update \
    && apt-get install -y \
        locales ca-certificates sudo openssh-client wget curl vim git rsync \
        language-pack-zh-hans tzdata ttf-wqy-microhei \
        software-properties-common apt-transport-https \
    && update-ca-certificates \
    && groupadd -o -g $USER_GID $USER_NAME \
    && useradd -Nmo -g $USER_GID -u $USER_ID $USER_NAME \
    && echo 'Defaults env_keep += "HTTP_PROXY HTTPS_PROXY NO_PROXY http_proxy https_proxy no_proxy"' >> /etc/sudoers \
    && echo "$USER_NAME ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && wget --no-check-certificate -O- https://dl.winehq.org/wine-builds/Release.key | apt-key add - \
    && apt-add-repository -y https://dl.winehq.org/wine-builds/ubuntu \
    && dpkg --add-architecture i386

RUN apt-get -y update && apt-get install -y --allow-unauthenticated --install-recommends winehq-stable zenity

RUN wget --no-check-certificate -O /usr/local/bin/winetricks https://github.com/Winetricks/winetricks/raw/master/src/winetricks \
    && chmod 755 /usr/local/bin/winetricks

ENV LC_CTYPE="zh_CN.UTF-8" LANG="zh_CN.UTF-8" LC_ALL="zh_CN.UTF-8" LANGUAGE="zh_CN.UTF-8" \
    TZ=Asia/Shanghai \
    DISPLAY=:0 \
    DEBIAN_FRONTEND=noninteractive

RUN locale-gen zh_CN.UTF-8

#WINEARCH=win32 /usr/bin/wine wineboot
#/usr/local/bin/winetricks -q win7
#/usr/local/bin/winetricks -q allfonts
#/usr/local/bin/winetricks -q allcodecs
#/usr/local/bin/winetricks -q cmd
#/usr/local/bin/winetricks -q d3dx10
#/usr/local/bin/winetricks -q d3dx9
#/usr/local/bin/winetricks -q dotnet48
#/usr/local/bin/winetricks -q ie8
#/usr/local/bin/winetricks -q ie8_kb2936068
#/usr/local/bin/winetricks -q vcrun2017
#/usr/local/bin/winetricks -q vcrun6
