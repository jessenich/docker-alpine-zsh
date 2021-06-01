# Docker Alpine Base Image

## Contents

Baseline image used in all deriving alpine based image. With the following installed & pre-configured:

- zsh
- oh-my-zsh
- bash
- git
- ssh
- sshd

## Building

- Copy `default.env` -> `.env`
- Build from source with 
  - `docker build . -t jessenich91/alpine-base:latest -t jessenich91/alpine-base:glibc-latest -t jessenich91/alpine-base:alpine-3.13-glibc-0.0.2-alpha -t jessenich91/alpine-base:glibc-0.0.2-alpha`
- Run with docker run --env-file "./default.env" --publish "2222:22" -v "./conf.d/:/etc/vol" --name "alpine-container" 