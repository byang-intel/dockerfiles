#!/bin/bash -e

DOCKERFILE_DIR=$1
OS=$2
VER=$3
if [ "x$VER" != "x" ]; then
	TAG=$DOCKERFILE_DIR:$VER
else
	TAG=$DOCKERFILE_DIR
fi

if [ "x$OS" != "x" ]; then
	dockerfile=$DOCKERFILE_DIR/Dockerfile.$OS
	TAG=$OS/$TAG
else
	dockerfile=$DOCKERFILE_DIR/Dockerfile
fi

sudo -E docker build -t $TAG --build-arg http_proxy --build-arg https_proxy -f $dockerfile .
