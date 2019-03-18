FROM byangintel/opencv-ubuntu-arm64
MAINTAINER bin.yang@intel.com
WORKDIR /opt/build

RUN apt-get -y update

RUN apt-get install -y ca-certificates \
	&& update-ca-certificates

RUN apt-get install -y --no-install-recommends vim git curl cmake build-essential libmicrohttpd-dev libcurl4-openssl-dev libyaml-dev python3-paho-mqtt

# edgex device sdk
RUN wget --no-check-certificate https://github.com/edgexfoundry/device-sdk-c/archive/0.7.1.tar.gz \
	&& tar -xzf 0.7.1.tar.gz \
	&& cd device-sdk-c-0.7.1 \
	&& ./scripts/build.sh \
	&& cp -rf include/* /usr/include/ \
	&& cp build/release/c/libcsdk.so /usr/lib

# mraa
COPY edgex-pi-demo-arm64/rpi_patch /opt/build/rpi_patch
RUN git clone https://github.com/intel-iot-devkit/mraa.git \
	&& cd mraa \
	&& git reset --hard d320776 \
	&& patch -p1 < /opt/build/rpi_patch \
	&& mkdir -p build && cd build && cmake -DBUILDSWIG=OFF -DCMAKE_INSTALL_PREFIX=/usr .. \
	&& make && make install

ENTRYPOINT ["/usr/local/bin/tini", "-g", "--"]
CMD ["/bin/sh"]
