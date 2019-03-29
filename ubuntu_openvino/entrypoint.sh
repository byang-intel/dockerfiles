#!/bin/bash

source /opt/intel/computer_vision_sdk/bin/setupvars.sh
export PATH=/opt/openvino/samples:$PATH

: ${TARGET:="CPU"}

openvino_model_path()
{
	if [ "$target" = "MYRIAD" ]; then
		# MYRIAD supports networks with FP16 format only
		target_precision="FP16"
	else
		target_precision="FP32"
	fi
	echo $INTEL_CVSDK_DIR/deployment_tools/intel_models/$1/$target_precision/$1.xml
}

exec "$@"
