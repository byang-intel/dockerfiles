FROM centos:7.6.1810
MAINTAINER bin.yang@intel.com
WORKDIR /opt/openvino

# COMMON BUILD TOOLS
RUN yum install -y -q bzip2 make autoconf libtool git wget ca-certificates pkg-config gcc gcc-c++ bison flex patch epel-release sudo gtk2-devel

# We need new cmake version
ARG CMAKE_VER=3.13.1
ARG CMAKE_REPO=https://cmake.org/files
RUN wget -O - ${CMAKE_REPO}/v${CMAKE_VER%.*}/cmake-${CMAKE_VER}.tar.gz | tar xz; \
	cd cmake-${CMAKE_VER}; \
	./bootstrap --prefix="/usr"; \
	make -j8; \
	make install

# Install openvino
RUN wget -O - http://registrationcenter-download.intel.com/akdlm/irc_nas/15078/l_openvino_toolkit_p_2018.5.455.tgz | tar xz; \
	cd l_openvino_toolkit_p_2018.5.455 \
	&& ./install_cv_sdk_dependencies.sh -y \
	&& sed -i 's/^\(ACCEPT_EULA\)=.*$/\1=accept/' silent.cfg \
	&& ./install.sh -s silent.cfg \
	&& mkdir -p /opt/build \
	&& cd /opt/build \
	&& source /opt/intel/computer_vision_sdk/bin/setupvars.sh \
	&& cmake -DCMAKE_BUILD_TYPE=Release /opt/intel/computer_vision_sdk/inference_engine/samples \
	&& make -j$(nproc) \
	&& cp -a /opt/build/intel64/Release /opt/openvino/samples

COPY centos_openvino/entrypoint.sh /opt/openvino/
RUN chmod +x /opt/openvino/entrypoint.sh

ENV TINI_VERSION v0.18.0
RUN mkdir -p /usr/local/bin
RUN wget -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini"
RUN chmod +x /usr/local/bin/tini

ENTRYPOINT ["/usr/local/bin/tini", "-g", "--"]
CMD ["/bin/bash"]
