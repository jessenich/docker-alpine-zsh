#!/usr/bin/env zsh

zparseopts -A zopts -source: -dest:

local source_dotenv="$zopts[--source]"
local dest_dotenv="$zopts[--dest]"

if [ -z "$soure_dotenv" ] then source_dotenv="${PWD}/default.env" fi
if [ -z "$dest_dotenv" ] then dest_dotenv="${PWD}/.env" fi

cp "${source_dotenv}" "${dest_dotenv}"