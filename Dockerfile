## MIT License
##
## Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.

ARG VARIANT="latest"

FROM jessenich91/alpine:"${VARIANT}" as deps

LABEL maintainer="Jesse N. <jesse@keplerdev.com>"
LABEL org.opencontainers.image.source="https://github.com/jessenich/docker-alpine-zsh/blob/main/Dockerfile"

ENV VARIANT=${VARIANT} \
    USER_LOGIN_SHELL="${USER_LOGIN_SHELL:-/bin/zsh}" \
    USER_LOGIN_SHELL_FALLBACK="${USER_LOGIN_FALLBACK_SHELL:-/bin/ash}" \
    TZ="${TZ:-America/NewYork}" \
    RUNNING_IN_DOCKER="true" \
    DISTRIBUTION="$(uname -a)"

USER root
RUN apk update 2>/dev/null && \
    apk add \
        zsh \
        zsh-syntax-highlighting \
        zsh-autosuggestions \
        rsync-zsh-completion \
        yq-zsh-completion;

RUN rm -rf /var/cache/apk/*
RUN chmod 0640 /etc/shadow

COPY ./lxfs /
RUN USER="$(cat /etc/passwd | grep ':1000:1000:' | awk -F':' '{ print $1 }')" && \
    if [ -n "${USER}" ]; then \
        chsh -s /bin/zsh "${USER}"; \
        cp /etc/zsh/zshrc_template "/home/${USER}/.zshrc"; \
    else \
        echo "No non-root accounts found to zsh-ify."; \
    fi

RUN chsh -s /bin/zsh root && \
    USER="$(cat /etc/passwd | grep ':1000:1000:' | awk -F':' '{ print $1 }')";

WORKDIR "/home/${USER}"
CMD "/bin/zsh"
