#!/bin/sh

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

image_version= ;

push= ;
no_glibc= ;
no_docs="false";
alpine_version="latest";
glibc_version="8.1_p1-r0";
registry="jessenich91";
repository="alpine-zsh";
target_stage="glibc";


show_usage() {
    echo  "Usage: $0 -i [--image-version] x.x.x [FLAGS]" && \
    echo "Flags: " && \
    echo "    -i | --image-version          - Semantic version compliant string to tag built image with." && \
    echo "    -g | --glibc-version          - glibc Version to install during build process. Empty value will assume latest version unless --no-glibc is specified. Including glibc will increase image size significantly." && \
    echo "    -a | --alpine-version         - Semantic version compliant string that coincides with underlying base Alpine image. See dockerhub.com/alpine for values. 'latest' is considered valid." && \
    echo "    [ --no-docs ]                 - Flag indicating whether to include accompanying documentation packages. Including docs will increase image size significantly." && \
    echo "    [ --no-glibc ]                - Flag indicating whether glibc should be excluded entirely. Presence of this flag overrides version specified in -g | [--no-glibc]. Including glibc will increase image size significantly." && \
    echo "    [ --registry ]                - Registry which the image will be pushed upon successful build. If not using dockerhub, the full FQDN must be specified. This assumes the default docker daemon is already authenticated with the registry specified. If dockerhub is used, just the username is required. Default value: jessenich91." && \
    echo "    [ --repository ]              - Repository which the image will be pushed upon successful build. Default value: 'alpine-zsh'"
}

build() {
    tag1="latest-${image_version}"
    tag2="${image_version}"
    repository_root="."

    if [ "${glibc_version}" != "none" ]; then
        target_stage="glibc";

        if [ -n "${no_docs}" ]; then 
            tag1="no-docs-glibc-latest";
            tag2="no-docs-glibc-${image_version}";       
            
        else
            tag1="glibc-latest";
            tag2="glibc-${image_version}";
        fi
    else
        if [ -n "${no_docs}" ]; then        
            tag1="no-docs-latest";
            tag2="no-docs-${image_version}";
        else
            tag1="latest";
            tag2="${image_version}";
        fi
    fi

    docker buildx build \
        -f "${repository_root}/Dockerfile" \
        -t "${registry}/${repository}:${tag1}" \
        -t "${registry}/${repository}:${tag2}" \
        --build-arg "ALPINE_VERSION=${alpine_version}" \
        --build-arg "NO_DOCS=${include_docs}" \
        --platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
        --target "${target_stage}" \
        --push \
        "${repository_root}"
}

main() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h | --help) 
                show_usage;
                exit 1;
            ;;

            -i | --image-version)
                image_version="$2";
            ;;

            -g | --glibc-version)
                glibc_version="$2"; 
            ;;

            -a | --alpine-version)
                alpine_version="$2";
            ;;

            -p | --push)
                push="true";
            ;;

            --no-glibc)
               no_glibc="true";
            ;;

            --no_docs) 
                no_docs="true"; 
            ;;

            --registry)
                registry="$2";
            ;;

            --repository)
                repository="$2";
            ;;
        esac
        shift
    done
}

main "$@"

## If we've reached this point without a valid --image-version, show usage info and exit with error code.
if [ -z "${image_version}" ]; then
    show_usage;
    exit 1;
fi

## unset glibc_version when --no-glibc flag is specified. 
## --no-glibc is intended to override --glibc-version parameter.
if [ -n "${no_glibc}" ] && [ ! -z "${glibc_version}" ]; then
    unset glibc_version;
fi

build

exit 0;