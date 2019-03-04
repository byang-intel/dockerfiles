#!/bin/bash -e

sudo docker build -t $1 --build-arg http_proxy --build-arg https_proxy -f $1/Dockerfile .
