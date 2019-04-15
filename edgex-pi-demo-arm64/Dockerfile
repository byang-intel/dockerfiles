FROM arm64v8/ubuntu:bionic
MAINTAINER bin.yang@intel.com
WORKDIR /opt/build

COPY hooks/qemu-aarch64-static /usr/bin/

RUN apt-get -y update \
	&& apt-get install -y --no-install-recommends \
		wget \
		psmisc vim git curl cmake build-essential \
		python3-opencv python-opencv python3-flask python-flask \
		libmicrohttpd-dev libcurl4-openssl-dev libyaml-dev python3-paho-mqtt

RUN apt-get install -y --no-install-recommends ca-certificates \
	&& update-ca-certificates

# edgex device sdk
RUN wget --no-check-certificate https://github.com/edgexfoundry/device-sdk-c/archive/0.7.1.tar.gz \
	&& tar -xzf 0.7.1.tar.gz \
	&& cd device-sdk-c-0.7.1 \
	&& ./scripts/build.sh \
	&& cp -rf include/* /usr/include/ \
	&& cp build/release/c/libcsdk.so /usr/lib

# mraa
COPY rpi_patch /opt/build/rpi_patch
RUN git clone https://github.com/intel-iot-devkit/mraa.git \
	&& cd mraa \
	&& git reset --hard d320776 \
	&& patch -p1 < /opt/build/rpi_patch \
	&& mkdir -p build && cd build && cmake -DBUILDSWIG=OFF -DCMAKE_INSTALL_PREFIX=/usr .. \
	&& make && make install

COPY edgex-pi-demo /opt/edgex-pi-demo
RUN cd /opt/edgex-pi-demo \
	&& mkdir build \
	&& cd build \
	&& cmake ../src \
	&& make

RUN wget --no-check-certificate https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-3.3.4-arm64-64bit-static.tar.xz \
        && tar xvf ffmpeg-3.3.4-arm64-64bit-static.tar.xz \
	&& cp -f ffmpeg-3.3.4-arm64-64bit-static/ffserver /usr/local/bin/ \
	&& cp -f ffmpeg-3.3.4-arm64-64bit-static/ffmpeg /usr/local/bin/

COPY ffserver.conf /opt/edgex-pi-demo/ffserver.conf

ENV TINI_VERSION v0.18.0
RUN mkdir -p /usr/local/bin
RUN wget --no-check-certificate -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini-arm64"
RUN chmod +x /usr/local/bin/tini

WORKDIR /opt/edgex-pi-demo

ENTRYPOINT ["/usr/local/bin/tini", "-g", "--"]
CMD ["/opt/edgex-pi-demo/start.sh"]
