FROM byangintel/centos_openvino
MAINTAINER bin.yang@intel.com
WORKDIR /opt/openvino

COPY openvino_face_detect/entrypoint.sh /opt/openvino/

ENTRYPOINT ["/usr/local/bin/tini", "-g", "/opt/openvino/entrypoint.sh", "--"]
CMD ["/bin/bash"]
