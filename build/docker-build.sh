#!/bin/zsh
 
image_version=
alpine_version=
openssh_version=
include_docs=
glibc_version=

show_usage() {
    echo  '
Usage: 
    /bin/sh docker-build.sh
        -i | --image-version x.x.x                   REQUIRED: specify required image tag
        [ --alpine-version=3.13 ]               OPTIONAL: specify optional alpine version
        [ --glibc-version=8.1_p1-r0 ]         OPTIONAL: specify optional openssh-version'
}

build() {
    local tag1="latest-${image_version}"
    local tag2="${image_version}"

    local alpine_version=${alpine_version:-3.13}
    local openssh_version=${openssh_version:-8.1_p1-r0}
    local glibc_version=${glibc_version:-false}
    local incude_docs=${include_docs:-true}
    local registry="jessenich91"
    local repository="alpine-zsh"
    local repository_root="."
    local target_stage="ohmyzsh"

    if [ "${glibc_version}" != "false" ]; then
        target_stage="glibc";

        if [ "${include_docs}" = "true" ]; then        
            tag1="glibc-latest";
            tag2="glibc-${image_version}";
        else
            tag1="prod-glibc-latest";
            tag2="prod-glibc-${image_version}";
        fi
    else
        if [ "${include_docs}" = "true" ]; then        
            tag1="latest";
            tag2="${image_version}";
        else
            tag1="prod-latest";
            tag2="prod-${image_version}";
        fi
    fi

    docker buildx build \
        -f "${repository_root}/Dockerfile" \
        -t "${registry}/${repository}:${tag1}" \
        -t "${registry}/${repository}:${tag2}" \
        --build-arg "ALPINE_VERSION=${alpine_version}" \
        --build-arg "OPENSSH_VERSION=${openssh_version}" \
        --build-arg "INCLUDE_DOCS=${include_docs}" \
        --target "${target_stage}" \
        "${repository_root}"
}

main() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -i | --image-version)
                if [ -z "$2" ]; then 
                    show_usage;
                    exit 1;
                else
                    image_version="$2";
                fi
            ;;
            --alpine-version)
                alpine_version="$2";
                ;;
            --openssh_version) 
                openssh_version="$2";
                ;;
            --glibc-version)
                glibc_version="$2"; 
                ;;
            --exclude_docs) 
                include_docs="false"; 
                ;;
            --registry)
                registry="$2";
                ;;
            --repository)
                repository="$2";
                ;;
            -h | --help) 
                show_usage 
                ;;
            *)
                if [ -z "${image_version}" ]; then
                    show_usage;
                fi
                ;;
        esac
        shift
    done

    echo $glibc_version
    echo $include_docs 

    build
}

main "$@"

exit 0;