#!/bin/bash -e

export PS1='\[\e[38;5;39m\]\u\[\e[0m\]@\[\e[38;5;208m\]\H \[\e[38;5;39m\]\w \[\e[38;5;39m\]$ \[\e[0;0m\]'

#search local DISPLAY: ps e | grep -Po " DISPLAY=[\.0-9A-Za-z:]* " | sort -u
if [ -n "$DISPLAY" ]; then
	xhost +local:root
fi

IMG_NAME=`echo $PWD | awk -F "/" '{print $NF}'`

sudo -E docker run --rm=true \
	--network host --env PS1 --env http_proxy --env https_proxy \
	--env DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
	-it $IMG_NAME $@
