FROM ubuntu:bionic
MAINTAINER bin.yang@intel.com
WORKDIR /opt/ffmpeg

RUN apt-get -y update \
	    && apt-get install -y --no-install-recommends \
	    tar xz-utils

ADD https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-3.3.4-64bit-static.tar.xz /opt/ffmpeg/
RUN tar xvf ffmpeg-3.3.4-64bit-static.tar.xz \
	&& cp -f ffmpeg-3.3.4-64bit-static/ffserver /usr/local/bin/ \
	&& cp -f ffmpeg-3.3.4-64bit-static/ffmpeg /usr/local/bin/ \
	&& rm -f ffmpeg-3.3.4-64bit-static.tar.xz

COPY ffserver.conf /opt/ffmpeg/ffserver.conf
COPY start.sh /opt/ffmpeg/start.sh

ENV TINI_VERSION v0.18.0
RUN mkdir -p /usr/local/bin
ADD https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini /usr/local/bin/

RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/tini", "-g", "--"]
CMD ["/opt/ffmpeg/start.sh"]
