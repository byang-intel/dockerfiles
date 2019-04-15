#!/bin/sh

: ${OUTPUT_STREAM:='http://localhost:49990/camera.ffm'}
export OUTPUT_STREAM

: ${MQTT_BROKER_PORT:=1883}
TAG=`$MQTT_BROKER_ADDR:$MQTT_BROKER_PORT | md5sum | cut -d' ' -f 1`

cat > /tmp/sensor-dist-reg.json <<__EOF__
{
    "name":"EdgeX/SensorDist/$MQTT_BROKER_ADDR/$MQTT_BROKER_PORT",
    "addressable":{
        "name":"EdgeX/SensorDist/$MQTT_BROKER_ADDR/$MQTT_BROKER_PORT",
        "protocol":"tcp",
        "address":"$MQTT_BROKER_ADDR",
        "port":$MQTT_BROKER_PORT,
        "publisher":"EdgeX/SensorDist",
        "topic":"EdgeX/SensorDist"
    },
    "format":"JSON",
    "filter":{
        "deviceIdentifiers":["GroveDevice"]
    },
    "enable":true,
    "destination":"MQTT_TOPIC"
}
__EOF__

curl -X POST -d @/tmp/sensor-dist-reg.json http://edgex-export-client:48071/api/v1/registration

: ${VIDEOSIZE:=640x480}
sed -i "s/VideoSize.*/VideoSize $VIDEOSIZE/g" /opt/edgex-pi-demo/ffserver.conf
/usr/local/bin/ffserver -f /opt/edgex-pi-demo/ffserver.conf &

while true; do
	python3 /opt/edgex-pi-demo/edgex-mqtt-command.py
	echo Fail to connect $MQTT_BROKER_ADDR:$MQTT_BROKER_PORT...
	sleep 3
done &

while true; do
	/opt/edgex-pi-demo/build/device-grove -c /opt/edgex-pi-demo/res/
	echo device-grove exit un-expected, restart...
done
