#!/usr/bin/env zsh

set -eo

zparseopts -A zopts -sshd::

local sshd_entry="$zopts[--sshd]";