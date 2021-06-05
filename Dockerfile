ARG ALPINE_VERSION="${ALPINE_VERSION:-3.13.5}"

FROM alpine:"${ALPINE_VERSION}" as deps

LABEL maintainer Jesse N. <jesse@keplerdev.com>

ARG OPENSSH_VERSION="${OPENSSH_VERSION:-8.1_p1-r0}"

ENV GLIBC_VERSION="2.33-r0" \
    USER_LOGIN_SHELL="/bin/zsh" \
    USER_LOGIN_SHELL_FALLBACK="/bin/ash" \
    RUNNING_IN_DOCKER="true"

RUN export RUNNING_IN_DOCKER

# Add dependencies
RUN apk add --update --no-cache \
    apk-tools-zsh-completion \
    bash \
    bash-completion \
    zsh \
    git \
    github-cli \
    github-cli-doc \
    git-zsh-completion \
    git-doc \
    git-diff-highlight \
    git-gitweb \
    git-zsh-completion \
    nano \
    zsh-autosuggestions \
    rsync \
    curl \
    wget \
    rsync-zsh-completion

SHELL ["/bin/zsh", "-c"]

FROM deps as ohmyzsh

RUN /bin/zsh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
COPY resources/zshrc ~/.zshrc
RUN source ~/.zshrc

FROM ohmyzsh as glibc

# Download and install glibc
RUN curl -sSLo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
  curl -sSLo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
  curl -sSLo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
  apk add glibc-bin.apk glibc.apk && \
  /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
  echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf
