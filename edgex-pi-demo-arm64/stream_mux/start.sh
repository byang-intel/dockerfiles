#!/bin/sh

: ${INPUT_STREAM:='http://localhost'}
export INPUT_STREAM

cp -f disconnected.jpg out.jpg
/usr/local/bin/mjpeg_httpd.py &

while true; do
	/usr/local/bin/stream_poll.py $INPUT_STREAM
	echo stream poll exits un-expected, restart...
    sleep 1
done 2>/dev/null
