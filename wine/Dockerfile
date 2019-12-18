FROM byangintel/desktop-xfce4:1.00

COPY sources.list /etc/apt/sources.list

ENV LC_CTYPE="zh_CN.UTF-8" LANG="zh_CN.UTF-8" LC_ALL="zh_CN.UTF-8" LANGUAGE="zh_CN.UTF-8" \
    TZ=Asia/Shanghai \
    DISPLAY=:0 \
    DEBIAN_FRONTEND=noninteractive

RUN locale-gen zh_CN.UTF-8

RUN apt-get -y update && apt-get install -y wget software-properties-common apt-transport-https && \
    wget -O - -nc https://dl.winehq.org/wine-builds/Release.key | apt-key add - && \
    apt-add-repository -y https://dl.winehq.org/wine-builds/ubuntu && \
    dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
        sudo \
        cabextract unzip python-numpy \
        language-pack-zh-hans tzdata ttf-wqy-microhei

RUN apt-get update && apt-get install -y --allow-unauthenticated --install-recommends winehq-stable

RUN    wget -O /usr/local/bin/winetricks https://github.com/Winetricks/winetricks/raw/master/src/winetricks && \
    chmod 755 /usr/local/bin/winetricks

#    apt-get purge -y software-properties-common apt-transport-https && \
#    apt-get autoremove -y && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists
