#!/bin/bash

set -x
mosquitto -v -d

tail -f /dev/null
wait
