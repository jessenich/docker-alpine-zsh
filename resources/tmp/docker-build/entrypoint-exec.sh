#!/bin/sh

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

CMD="$1"
shift
PARAMS=( $@ )

# set user group and home
set-user-group-home

# chown path
chown-path

# exec CMD
exec "$CMD" "${PARAMS[@]}"