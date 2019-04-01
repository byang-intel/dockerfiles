Run face detect with GPU target:

```
sudo docker run --rm=true --privileged=true --env TARGET=GPU --env INPUT_STREAM=<stream url> -p 49990:49990 -v /dev:/dev -it byangintel/openvino-face_detect-centos
```

Run face detect with MYRIAD target:
```
mkdir -p /etc/udev/rules.d/
cp 97-myriad-usbboot.rules /etc/udev/rules.d/
# apply udev change

sudo docker run --rm=true --privileged=true --network=host --env TARGET=MYRIAD --env INPUT_STREAM=<stream url> -p 49990:49990 -v /dev:/dev -v /sys:/sys -it byangintel/openvino-face_detect-centos
```
