#!/bin/bash -e

sudo -E docker build -t $2 --build-arg http_proxy --build-arg https_proxy -f $1 .
