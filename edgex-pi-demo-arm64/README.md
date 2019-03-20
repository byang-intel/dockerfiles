# EdgeX Pi Demo

- [Host Setup](#Host-Setup)
- [Pi Setup](#Pi-Setup)
- [MQTT Message Format](#MQTT-Message-Format)
- [Face Detection Result](#Face-Detection-Result)
- [Demo](#Demo)

## Host Setup
Firstly, it needs to prepare the docker service on your host machine.

Then, start demo services with below steps:
1. Download host-docker-compose.yml and hivemq config file
```
wget https://raw.githubusercontent.com/byang-intel/dockerfiles/master/edgex-pi-demo-arm64/hivemq.conf
wget -O docker-compose.yml https://raw.githubusercontent.com/byang-intel/dockerfiles/master/edgex-pi-demo-arm64/host-docker-compose.yml
```

2. Modify the Pi board addr in docker-compose.yml
```
sed 's/INPUT_STREAM=.*/INPUT_STREAM=http:\/\/<your pi board ip>:49990/g' -i docker-compose.yml
```

3. Launch all services
```
docker-compose up -d
```

## Pi Setup

Pi Version: Raspberry Pi 3B/3B+

Pin connection:

    Red-LED: GPIO 13

    Green-LED: GPIO 19

    Blue-LED: GPIO 26

    Distance Sensor:

        Trig Pin: GPIO 3

        Echo Pin: GPIO 4


Firstly, flash any linux distrubition and enable docker.

E.g. To install ubuntu, it can refer to below link

https://wiki.ubuntu.com/ARM/RaspberryPi

When docker service is ready, run EdgeX Pi Demo with below steps:

1. Download demo docker-compose.yml
```
wget https://raw.githubusercontent.com/byang-intel/dockerfiles/master/edgex-pi-demo-arm64/docker-compose.yml
```

2. Modify the broker addr in docker-compose.yml
```
sed 's/MQTT_BROKER_ADDR=.*/MQTT_BROKER_ADDR=<your host ip>/g' -i docker-compose.yml
```

3. Launch all services
```
docker-compose up -d
```
If the MQTT_BROKER_ADDR is modified, it needs to re-launch the services
```
docker-compose restart
```

## MQTT Message Format

### From Pi to Host:

    Topic: EdgeX/SensorDist

    Message Format: JSON

    Sample Code to decode the message
```
    if (message.topic == "EdgeX/SensorDist") {
        var raw = JSON.parse(message.payload);
        var data = {
            'device' : raw.readings[0].device,
            'name' : raw.readings[0].name,
            'distance' : raw.readings[0].value,
        };
    }
```

### From Host to Pi:

    Topic: EdgeX/Command

    Message Format: JSON

    Samples to control Leds and Camera:
```
    {"command":"Set_RedLed", "data":{"Red-LED":"true"}}
    {"command":"Set_RedLed", "data":{"Red-LED":"false"}}
    {"command":"Set_GreenLed", "data":{"Green-LED":"true"}}
    {"command":"Set_GreenLed", "data":{"Green-LED":"false"}}
    {"command":"Set_BlueLed", "data":{"Blue-LED":"true"}}
    {"command":"Set_BlueLed", "data":{"Blue-LED":"false"}}
    {"command":"camera_on"}
    {"command":"camera_off"}
```

## Face Detection Result

The result is Motion JPEG: http://host_ip:49990

## Demo

Demo video: [https://byang-intel.github.io/edgex-pi-demo-arm64/edgex-pi-demo.mp4](https://byang-intel.github.io/edgex-pi-demo-arm64/edgex-pi-demo.mp4)


1. Load WebUI (Tested on Chrome): [https://byang-intel.github.io/edgex-pi-demo-arm64/](https://byang-intel.github.io/edgex-pi-demo-arm64/)
2. Set the host ip and click connect button. The browser might warn "Insecure content blocked". Please enable the "unsafe scripts".
3. Subscript "EdgeX/SensorDist" to monitor distance sensor value
4. Enable the camera to stream the camera data from Pi to host for face detection.
5. Control the Led on/off
