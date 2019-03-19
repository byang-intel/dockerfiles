#!/bin/sh -e

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
python3 /opt/edgex-pi-demo/edgex-mqtt-command.py &
/opt/edgex-pi-demo/build/device-grove -c /opt/edgex-pi-demo/res/
