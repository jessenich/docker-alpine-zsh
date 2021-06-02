#!/usr/bin/env zsh

zparseopts -A zopts -image-version: -alpine-version:: -openssh-version:: -help::
 
local image_version="$zopts[--image-version]"
local alpine_version="$zopts[--alpine-version]"
local openssh_version="$zopts[--openssh-version]"
local help_arg="$zopts[--help]"
local repository_root="."

if [[ "$help_arg" ]] 
then
    echo 'Usage: 
        /bin/zsh docker-build.sh \ Call into script using zsh
            --image-version x.x.x \ specify required image tag
            [ --alpine-version=3.13.5 ] \ specify optional alpine version
            [ --openssh-version=8.1_p1-r0 ] specify optional openssh-version'
fi

if [[ -z "${alpine_version}" ]]
then
    alpine_version="3.13.5"
fi

if [[ -z "${openssh_version}" ]]
then
    openssh_version="8.1_p1-r0"
fi

docker buildx build \
    -f "${repository_root}"/amd64/Dockerfile \
    -t jessenich91/alpine-base:latest  \
    -t jessenich91/alpine-base:glibc-latest \
    -t jessenich91/alpine-base:glibc-"${image_version}" \
    -t jessenich91/alpine-base:"${image_version}" \
    --build-arg "ALPINE_VERSION=${alpine_version}" \
    --build-arg "OPENSSH_VERSION=${openssh_version}" \
    "${repository_root}"