#!/bin/sh

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

image_version= ;
variant="latest";
library="jessenich91";
repository="alpine-zsh";

show_usage() {
    echo "Usage: $0 -i [--image-version] x.x.x [FLAGS]" && \
    echo "Flags: " && \
    echo "    -i | --image-version          - Semantic version compliant string to tag built image with." && \
    echo "    -v | --variant                - Variant/tag of base image" && \
    echo "    [ --registry ]                - Registry which the image will be pushed upon successful build. If not using dockerhub, the full FQDN must be specified. This assumes the default docker daemon is already authenticated with the registry specified. If dockerhub is used, just the username is required. Default value: jessenich91." && \
    echo "    [ --repository ]              - Repository which the image will be pushed upon successful build. Default value: 'alpine-zsh'"
}

build() {
    tag1="latest"
    tag2="${image_version}"
    repository_root="."

    docker buildx build \
        -f "${repository_root}/Dockerfile" \
        -t "${library}/${repository}:${tag1}" \
        -t "${library}/${repository}:${tag2}" \
        -t "ghcr.io/${library}/${repository}:${tag1}" \
        -t "ghcr.io/${library}/${repository}:${tag2}" \
        --no-cache \
        --build-arg "VARIANT=${variant}" \
        --platform linux/amd64 \
        --pull \
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
                shift 2;
            ;;

            -v | --variant)
                variant="$2";
                shift 2;
            ;;

            -r | --repository)
                repository="$2";
                shift 2;
            ;;
        esac
    done
}

main "$@"

## If we've reached this point without a valid --image-version, show usage info and exit with error code.
if [ -z "${image_version}" ]; then
    show_usage;
    exit 1;
fi

build

exit 0;
