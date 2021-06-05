# Docker Alpine Base Image

## Contents

Baseline image used in all alpine based images with the following installed & pre-configured:

- glibc (Optional)*
- zsh
- oh-my-zsh
- bash
- git
- git utilities
- various zsh completion packages

## Building

- Copy `default.env` -> `.env`
- Build from source with `zsh` script at `build/docker-build.sh`
- Run container with `zsh` script at `build/docker-run.sh`
