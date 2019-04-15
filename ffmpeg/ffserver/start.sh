#!/bin/sh

: ${HTTPPort:=49990}
: ${VIDEOSIZE:=640x480}
sed -i "s/VideoSize.*/VideoSize $VIDEOSIZE/g" /opt/ffmpeg/ffserver.conf
sed -i "s/HTTPPort.*/HTTPPort $HTTPPort/g" /opt/ffmpeg/ffserver.conf
/usr/local/bin/ffserver -f /opt/ffmpeg/ffserver.conf
