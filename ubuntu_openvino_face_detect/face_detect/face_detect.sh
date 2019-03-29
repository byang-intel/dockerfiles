#!/bin/bash

set -x

source /opt/intel/computer_vision_sdk/bin/setupvars.sh
export PATH=/opt/openvino/samples:$PATH
export INTEL_CVSDK_DIR=/opt/intel/computer_vision_sdk

: ${TARGET:="CPU"}
: ${INPUT_STREAM:="/opt/face_detect/test_face_detect.mp4"}
echo $TARGET

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
	`dirname $0`/build/intel64/Release/face_detect_demo \
		-d $TARGET \
		-d_ag $TARGET \
		-m `openvino_model_path face-detection-adas-0001` \
		-m_ag `openvino_model_path age-gender-recognition-retail-0013` \
		-i $INPUT_STREAM
	sleep 10
done

wait
