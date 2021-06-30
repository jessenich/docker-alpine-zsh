group "default" {
    targets = [
        "ohmyzsh-docs-glibc",
        "ohmyzsh-docs-no-glibc",
        "ohmyzsh-no-docs-glibc", 
        "ohmyzsh-no-docs-no-glibc"
    ]
}

target "base-config" {
    args = {
        ALPINE_VERSION = "3.14.0"
    }
    context = "./"
    dockerfile = "Dockerfile"
    inherits = ["docker-metadata-action"]
    labels = {
        maintainer = "Jesse N. <jesse@keplerdev.com>"
        com.keplerdev.maintainer = "Jesse N. <jesse@keplerdev.com>"
        com.keplerdev.url = "https://keplerdev.com"
        com.keplerdev.image.name = "alpine-zsh"
        com.keplerdev.image.description = "Base Alpine image used by all deriving images developed by myself, and members of Kepler Development. Includes common packages such as rsync, ca-certificates, nano, curl, jq, yq, and zsh as the primary shell. OhMyZsh is also installed with some settings customized."
        com.keplerdev.image.network = "default"
        com.keplerdev.image.alpine-version = "3.14.0"
        com.keplerdev.image.registry = "https://dockerhub.com/u/jessenich91/alpine-zsh"
        com.keplerdev.image.repository = "https://github.com/jessenich/docker-alpine-zsh"
        
        
    }
    output = ["type=registry"]
    platforms = [
        "linux/amd64", 
        "linux/arm/v6", 
        "linux/arm/v7", 
        "linux/arm64", 
        "linux/386"
    ],
    pull = true
}

target "docker-metadata-action" { }

target "ohmyzsh-docs-glibc" {
    args = {
        GLIBC_VERSION = "2.33-r0"
        NO_DOCS = "false"
    }
    inherits = ["base-config"]
    labels = {
        com.keplerdev.image.glibc-version = "2.33-r0"
        com.keplerdev.image.no-docs = "false"
        com.keplerdev.image.tag = "latest"
        com.keplerdev.image.bake-target = "ohmyzsh-docs-glibc"
    }
    target = "glibc"
}

target "ohmyzsh-docs-no-glibc" {
    args = {
        NO_DOCS = "false"
    }
    inherits = ["base-config"]
    labels = {
        com.keplerdev.image.glibc-version = "null"
        com.keplerdev.image.no-docs = "false"
        com.keplerdev.image.tag = "no-glibc-latest"
        com.keplerdev.image.bake-target = "ohmyzsh-docs-no-glibc"
    }
    target = "ohmyzsh"
}

target "ohmyzsh-no-docs-glibc" {
    args = {
        GLIBC_VERSION = "2.33-r0"
        NO_DOCS = "true"
    }
    inherits = ["base-config"]
    labels = {
        com.keplerdev.image.glibc-version = "2.33-r0"
        com.keplerdev.image.no-docs = "true"
        com.keplerdev.image.tag = "no-docs-latest"
        com.keplerdev.image.bake-target = "ohmyzsh-no-docs-glibc"
    }
    target = "glibc"
}

target "ohmyzsh-no-docs-no-glibc" {
    args = {
        NO_DOCS = "true"
    }
    inherits = ["base-config"]
    labels = {
        com.keplerdev.image.glibc-version = "null"
        com.keplerdev.image.no-docs = "true"
        com.keplerdev.image.tag = "no-docs-no-glibc-latest"
        com.keplerdev.image.bake-target = "ohmyzsh-no-docs-no-glibc"
    }
    target = "ohmyzsh"
}