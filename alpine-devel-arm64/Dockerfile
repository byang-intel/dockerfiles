FROM arm64v8/alpine:3.8

COPY qemu-aarch64-static /usr/bin/

RUN apk add --update --no-cache vim build-base git gcc cmake make linux-headers yaml-dev libmicrohttpd-dev curl curl-dev python3

ENV TINI_VERSION v0.18.0
RUN mkdir -p /usr/local/bin
RUN curl -L -k  -o /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini-static-arm64"
RUN chmod +x /usr/local/bin/tini

ENTRYPOINT ["/usr/local/bin/tini", "-g", "--"]
CMD ["/bin/sh"]
