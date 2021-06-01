ARG ALPINE_VERSION="${ALPINE_VERSION:-3.13.5}"

FROM alpine:"${ALPINE_VERSION}"

LABEL maintainer Jesse N. <jesse@keplerdev.com>

ARG OPENSSH_VERSION="${OPENSSH_VERSION:-8.1_p1-r0}"

ENV GLIBC_VERSION="2.33-r0" \
    CONF_VOLUME="/conf.d" \
    OPENSSH_VERSION="${OPENSSH_VERSION}" \
    CACHED_SSH_DIRECTORY="${CONF_VOLUME}/ssh" \
    AUTHORIZED_KEYS_VOLUME="${CONF_VOLUME}/authorized_keys" \
    ROOT_KEYPAIR_LOGIN_ENABLED="false" \
    ROOT_LOGIN_UNLOCKED="false" \
    USER_LOGIN_SHELL="/bin/zsh" \
    USER_LOGIN_SHELL_FALLBACK="/bin/ash" \
    RUNNING_IN_DOCKER="true"

RUN export RUNNING_IN_DOCKER

# Add dependencies
RUN apk add \
    bash \
    bash-completion \
    zsh \
    git \
    vim \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    bind-tools \
    rsync \
    curl \
    wget \
    openssh

# Download and install glibc
RUN curl -sSLo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
  curl -sSLo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
  curl -sSLo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
  apk add glibc-bin.apk glibc.apk && \
  /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
  echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

RUN mkdir -p /root/.ssh "${CONF_VOLUME}" "${AUTHORIZED_KEYS_VOLUME}" && \
    cp -a /etc/ssh "${CACHED_SSH_DIRECTORY}"

RUN sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

RUN echo "export RUNNING_IN_DOCKER=true" >> ~/.zshrc && \
    echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc && \
    echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc

RUN rm -rf /var/cache/apk/*

EXPOSE 22
VOLUME "/etc/ssh"

SHELL ["${USER_LOGIN_SHELL}"]
ENTRYPOINT "./entrypoint.sh"