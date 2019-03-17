FROM arm64v8/ubuntu:bionic

COPY qemu-aarch64-static /usr/bin/

RUN apt-get update \
	&& apt-get -y upgrade \
	&& apt-get install -y --no-install-recommends wget python3-opencv python-opencv python3-flask python-flask

ENV TINI_VERSION v0.18.0
RUN mkdir -p /usr/local/bin
RUN wget --no-check-certificate -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini-arm64"
RUN chmod +x /usr/local/bin/tini

ENTRYPOINT ["/usr/local/bin/tini", "-g", "--"]
CMD ["/bin/bash"]
