#!/usr/bin/env bash

dockerio_library= ;
ghcr_library= ;
latest_tag= ;
semver_tag= ;

while [ "$#" -gt 0 ]; do
    case "$1" in
        -d | --dockerio-library)
            dockerio_library="$2";
            shift;;

        -g | --ghcr-library)
            ghcr_library="$2";
            shift;;
        
        -l | --latest-tag)
            latest_tag="$2";
            shift;;

        -s | --semver_tag)
            semver_tag="$2";
            shift;;
    esac
    shift;
done

get-docker-tag-args() {
    usage() {
        echo "Usage: derive_tag_args [-i | --image-name] (IMAGE_NAME)" >&2;
        echo "Example: derive_tag_args -i syslog-ng-daemon" >&2;
        echo 1
    };

    if [ "$1" = "-i" ] || [ "$1" = "--image-name" ]; then
        if [ -z "$2" ]; then exit "$(usage)"; fi
        image_name="$2";
    elif [ -n "$1" ]; then
        image_name="$1";
    else
        exit "$(usage)"
    fi
    
    cat <<EOF
-t ${dockerio_library}/${image_name}:${latest_tag} \
-t ${dockerio_library}/${image_name}:${semver_tag} \
-t ${ghcr_library}/${image_name}:${latest_tag} \
-t ${ghcr_library}/${image_name}:${semver_tag}
EOF
}