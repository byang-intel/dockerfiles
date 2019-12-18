#!/bin/bash -e

IMG_NAME=`echo $PWD | awk -F "/" '{print $NF}'`
sudo -E docker build -t $IMG_NAME --build-arg http_proxy --build-arg https_proxy .
