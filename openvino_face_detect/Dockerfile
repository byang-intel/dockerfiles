FROM byangintel/centos_openvino
MAINTAINER bin.yang@intel.com
WORKDIR /opt/openvino

RUN yum install -y -q python-flask

COPY openvino_face_detect/face_detect /opt/face_detect
RUN cd /opt/face_detect/ \
	&& mkdir build \
	&& cd build \
	&& source /opt/intel/computer_vision_sdk/bin/setupvars.sh \
	&& cmake -DCMAKE_BUILD_TYPE=Release ../ \
	&& make -j$(nproc)

ENTRYPOINT ["/usr/local/bin/tini", "-g", "/opt/face_detect/face_detect.sh", "--"]
