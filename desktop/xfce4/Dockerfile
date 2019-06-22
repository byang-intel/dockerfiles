FROM ubuntu:18.04
MAINTAINER bin.yang@intel.com

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE='en_US:en' \
	DISPLAY=:0 \
	DEBIAN_FRONTEND=noninteractive

# Don't start any optional services except for the few we need.
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \;

RUN systemctl set-default multi-user.target

RUN apt-get -y update \
	&& apt-get install -y \
		ca-certificates sudo wget curl vim git openssh-server \
		net-tools inetutils-ping \
		supervisor xfce4 xfce4-terminal locales ttf-wqy-zenhei xterm firefox vnc4server

RUN update-ca-certificates \
	&& locale-gen en_US.UTF-8 \
	&& echo "root:123456" | chpasswd \
	&& sed 's/#PasswordAuthentication.*/PasswordAuthentication yes/g' -i /etc/ssh/sshd_config \
	&& sed 's/PermitRootLogin.*/PermitRootLogin yes/g' -i /etc/ssh/sshd_config

RUN systemctl mask nptd avahi-daemon avahi-daemon.socket systemd-udevd.service udisks2.service

RUN mkdir -p /opt/noVNC \
	&& wget --no-check-certificate -O- https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar -xzf - -C /opt/noVNC --strip-components=1 \
	&& mkdir -p /opt/noVNC/utils/websockify \
	&& wget --no-check-certificate -O- https://codeload.github.com/novnc/websockify/tar.gz/master | tar -xzf - -C /opt/noVNC/utils/websockify  --strip-components=1

# passwd: 123456
COPY root/.config /root/.config
COPY root/.vnc /root/.vnc
RUN chmod 600 /root/.vnc/passwd
COPY vncserver@:0.service /etc/systemd/system/vncserver@:0.service
RUN systemctl enable vncserver@:0.service
COPY noVNC.service /etc/systemd/system/noVNC.service
RUN systemctl enable noVNC.service

COPY localtime /etc/localtime
RUN echo "Asia/Shanghai" > /etc/timezone

VOLUME /dev
VOLUME /sys/fs/cgroup

# noVNC
EXPOSE 6080
EXPOSE 22

CMD ["/sbin/init"]
