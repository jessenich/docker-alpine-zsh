# Docker Alpine Base Image

*GitHub Source* https://github.com/jessenich/docker-alpine-zsh

*DockerHub Registry* https://dockerhub.com/r/jessenich91/alpine-zsh

`docker pull jessenich91/alpine-zsh:latest`

## Contents

Baseline image used in all alpine based images built for multiarch with the following installed & pre-configured:

- ca-certificates
- rsync
- nano
- curl
- wget
- jq
- yq
- zsh
- oh-my-zsh
- glibc (Optional)*
- man-docs (Optional)*

## Run

Run latest, standard variant. Includes man-docs and glibc:

`docker -rm -it jessenich91/alpine-zsh:latest`

Run latest, no-doc variant. Includes glibc:

`docker -rm -it jessenich91/alpine-zsh:no-docs-latest`

Run latest, no glibc variant. Includes docs:

`docker -rm -it jessenich91/alpine-zsh:no-glibc-latest`

Run latest, no glibc, no docs:

`docker -rm -it jessenich91/alpine-zsh:no-glibc-docs-latest`

To run a specific version of any variant specify the semver in place of latest:

`docker -rm -it jessenich91/alpine-zsh:no-docs-1.2.0`
