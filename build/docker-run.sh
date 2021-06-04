#!/usr/bin/env zsh

set -eo

zparseopts -A zopts -env-file:: -name:: -ssh-port:: -ssh-conf-vol::

local env_file="$zopts[--env-file]"
local name="$zopts[--name]"
local ssh_port="$zopts[--port]"
local vol="$zopts[--ssh-conf-vol]"

if [[ -z "${env_file}" ]]
then
    env_file="./default.env";
fi

if [[ -z "${name}" ]]
then
    name="alpine-base"
fi

# if [[ -z "$vol" ]]
# then
#     vol="./resources/etc/ssh"
# fi

    # -p "${ssh_port}:22" \
    # --mount "${vol}":/etc/ssh

docker run -it \
    --name "${name}" \
    --env-file "${env_file}" \
    jessenich91/alpine-base:latest