FROM ubuntu:18.04
MAINTAINER bin.yang@intel.com

ARG USER_NAME=byang
ARG USER_ID=1000
ARG USER_GID=1000
ARG USER_PASSWD="123456"

ENV LC_CTYPE="en_US.UTF-8" LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8" LANGUAGE="en_US:en" \
	DISPLAY=:0 \
	DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update \
	&& apt-get install -y systemd

# Don't start any optional services except for the few we need.
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \;

RUN systemctl set-default multi-user.target

RUN apt-get install -y sudo \
	&& groupadd -o -g $USER_GID $USER_NAME \
	&& useradd -Nmo -g $USER_GID -u $USER_ID $USER_NAME \
	&& echo "$USER_NAME:$USER_PASSWD" | chpasswd \
	&& echo 'Defaults env_keep += "HTTP_PROXY HTTPS_PROXY NO_PROXY http_proxy https_proxy no_proxy"' >> /etc/sudoers \
	&& echo "$USER_NAME ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN apt-get install -y locales \
	&& locale-gen en_US.UTF-8

RUN apt-get install -y ca-certificates \
	&& update-ca-certificates

RUN apt-get install -y \
		sudo wget curl vim git openssh-server \
		net-tools inetutils-ping \
		supervisor xfce4 xfce4-terminal ttf-wqy-zenhei xterm firefox vnc4server

RUN systemctl mask nptd avahi-daemon avahi-daemon.socket systemd-udevd.service udisks2.service

RUN mkdir -p /opt/noVNC \
	&& wget --no-check-certificate -O- https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar -xzf - -C /opt/noVNC --strip-components=1 \
	&& mkdir -p /opt/noVNC/utils/websockify \
	&& wget --no-check-certificate -O- https://codeload.github.com/novnc/websockify/tar.gz/master | tar -xzf - -C /opt/noVNC/utils/websockify  --strip-components=1

#vncserver -geometry 1280x800 :0
COPY root/.config /home/$USER_NAME/.config
COPY root/.vnc /home/$USER_NAME/.vnc
COPY noVNC.service /etc/systemd/system/noVNC.service
RUN systemctl enable noVNC.service
RUN chown $USER_NAME:$USER_NAME /home/$USER_NAME/.config -R \
	&& chown $USER_NAME:$USER_NAME /home/$USER_NAME/.vnc -R

COPY localtime /etc/localtime
RUN echo "Asia/Shanghai" > /etc/timezone

VOLUME /dev
VOLUME /sys/fs/cgroup

# noVNC
EXPOSE 6080
EXPOSE 22

CMD ["/sbin/init"]
