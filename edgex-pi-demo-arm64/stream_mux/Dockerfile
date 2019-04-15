FROM ubuntu:bionic
MAINTAINER bin.yang@intel.com
WORKDIR /opt/stream_mux/

RUN apt-get -y update \
	&& apt-get install -y --no-install-recommends \
		python3-opencv python-opencv python3-flask python-flask

ENV TINI_VERSION v0.18.0
RUN mkdir -p /usr/local/bin
ADD https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini /usr/local/bin/

COPY disconnected.jpg disconnected.jpg
COPY mjpeg_httpd.py /usr/local/bin/mjpeg_httpd.py
COPY stream_poll.py /usr/local/bin/stream_poll.py
COPY start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/tini", "-g", "--"]
CMD ["/usr/local/bin/start.sh"]
