#!/bin/bash

set -x

source /opt/intel/computer_vision_sdk/bin/setupvars.sh
export PATH=/opt/openvino/samples:$PATH

: ${TARGET:="CPU"}

openvino_model_path()
{
	if [ "$TARGET" = "MYRIAD" ]; then
		# MYRIAD supports networks with FP16 format only
		target_precision="FP16"
	else
		target_precision="FP32"
	fi
	echo $INTEL_CVSDK_DIR/deployment_tools/intel_models/$1/$target_precision/$1.xml
}

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

touch .lock

python `dirname $0`/http_mjpg.py &

while true; do
	cp -f `dirname $0`/disconnected.jpg out.jpg
	if [ -e /run/netns/host  ]; then
		ip netns exec host `dirname $0`/build/intel64/Release/face_detect_demo \
			-d $TARGET \
			-m `openvino_model_path face-detection-adas-0001` \
			-d_ag $TARGET \
			-m_ag `openvino_model_path age-gender-recognition-retail-0013` \
			-i $INPUT_STREAM
	else
		`dirname $0`/build/intel64/Release/face_detect_demo \
			-d $TARGET \
			-m `openvino_model_path face-detection-adas-0001` \
			-d_ag $TARGET \
			-m_ag `openvino_model_path age-gender-recognition-retail-0013` \
			-i $INPUT_STREAM
	fi
	sleep 1
done

wait
