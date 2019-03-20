#!/bin/bash -e

export PS1='\[\e[38;5;39m\]\u\[\e[0m\]@\[\e[38;5;208m\]\H \[\e[38;5;39m\]\w \[\e[38;5;39m\]$ \[\e[0;0m\]'

sudo -E docker run --restart always --name registry-mirror \
	-p 5000:5000 \
	--env PS1 --env http_proxy --env https_proxy --env no_proxy \
	-v /var/lib/registry:/var/lib/registry registry-mirror 
