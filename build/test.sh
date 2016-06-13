#!/bin/bash

system_image="randomarcher/archlinux:latest"

sudo docker pull $system_image
    
sudo docker run \
   --privileged \
   -d -t -i \
   -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
   -v /tmp:/tmp:rw \
   -v $PWD:$PWD:rw \
   $system_image
