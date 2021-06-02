#!/usr/bin/env zsh

zparseopts -A zopts -image-version: -alpine-version:: -openssh-version::
 
local image_version="$zopts[--image-version]"
local alpine_version="$zopts[--alpine-version]"
local openssh_version="$zopts[--openssh-version]"

if [[ -n "${alpine_version} "]];
then
    alpine_version="3.13.5"
fi

if [[ -n "${openssh_version}" ]];
then
    openssh_version="8.1_p1-r0"
fi

docker build . \
    -f ./amd64/Dockerfile \
    -t jessenich91/alpine-base:latest  \
    -t jessenich91/alpine-base:glibc-latest \
    -t jessenich91/alpine-base:glibc-"${image_version}" \
    -t jessenich91/alpine-base:alpine-"${alpine-version}"-glibc-"${image_version}" \
    --env-file ./default.env
    --build-arg "ALPINE_VERSION=${alpine_version}" \
    --build-arg "OPENSSH_VERSION=${openssh_version}"