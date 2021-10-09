export root_dir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
export SHELL = /bin/bash

$(info importing $(root_dir)docker/build/docker-build.mk)
include $(root_dir)docker/build/Makefile