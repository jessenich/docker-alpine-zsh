#!/usr/bin/env bash

zparseopts -A zopts -image-version: -alpine-version:: -openssh-version::

local image_version="$zopts[--image-version]"
local apine_version="$zopts[--alpine-version]"
local openssh_version="$zopts[--openssh-version]"

if [[ -n "${alpine_version} "]];
then
    exit 1;
fi

if [[ -n $"{openssh_version}" ]];
then
    exit 1;
fi

docker build . \
    -f ./amd64/Dockerfile \
    -t jessenich91/alpine-base:latest  \
    -t jessenich91/alpine-base:glibc-latest \
    -t jessenich91/alpine-base:glibc-0.0.2-alpha \
    -t jessenich91/alpine-base:alpine-3.13.5-glibc-0.0.2-alpha \
    --build-arg "ALPINE_VERSION=3.13.5" \
    --build-arg "OPENSSH_VERSION=8.1_p1-r0"