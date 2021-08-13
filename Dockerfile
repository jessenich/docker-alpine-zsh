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

ENV VARIANT=${VARIANT} \
    USER_LOGIN_SHELL="${USER_LOGIN_SHELL:-/bin/zsh}" \
    USER_LOGIN_SHELL_FALLBACK="${USER_LOGIN_FALLBACK_SHELL:-/bin/ash}" \
    TZ="${TZ:-America/NewYork}" \
    RUNNING_IN_DOCKER="true" \
    DISTRIBUTION="$(uname -a)"

USER root
RUN apk update && \
    apk add \
        zsh \
        zsh-syntax-highlighting \
        zsh-autosuggestions \
        shadow \
        rsync-zsh-completion \
        yq-zsh-completion;

RUN rm -rf /var/cache/apk/*

COPY ./lxfs /
RUN chsh -s /bin/zsh root && \
    USERS="$(cat /etc/passwd | grep '/bin/ash' | awk -F':' '{ print $1 }')" && \
    if [ "${USERS[#]}" -gt 1 ]; then \
        for user in "${USERS[@]}"; do \
            chsh -s /bin/zsh "${user}"; \
            cp /etc/zsh/zshrc_template "/home/${user}/.zshrc"; \
        done \
    else \
        chsh -s /bin/zsh "${USERS}"; \
        cp /etc/zsh/zshrc_template "/home/${user}/.zshrc"; \
    fi

COPY lxfs/home/user/zshrc /tmp/docker-build/zshrc
COPY lxfs/home/user/zsh /tmp/docker-build/zsh
