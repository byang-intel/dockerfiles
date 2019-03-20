FROM registry
MAINTAINER bin.yang@intel.com

ARG http_proxy
ENV http_proxy=$http_proxy

ARG https_proxy
ENV https_proxy=$https_proxy

ARG no_proxy
ENV no_proxy=$no_proxy

COPY registry-mirror/config.yml /etc/docker/registry/config.yml
