Run face detect with GPU target:

```
sudo docker run --rm=true --privileged=true --env TARGET=GPU --env INPUT_STREAM=<stream url> -p 49990:49990 -v /dev:/dev -it byangintel/openvino_face_detect
```
