this_dir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
docker_dir := $(root_dir)docker
images_root = $(docker_dir)

dockerio_username = $(shell cat $(docker_dir)/secrets/DOCKERHUB_USERNAME.secret)
ghcr_username = $(shell cat $(docker_dir)/secrets/GITHUB_ACTOR.secret)
dockerio_pat = $(shell cat $(docker_dir)/secrets/DOCKERHUB_TOKEN.secret)
ghcr_pat = $(shell cat $(docker_dir)/secrets/GITHUB_TOKEN.secret)

dockerio = docker.io
ghcr = ghcr.io
dockerio_library := $(dockerio)/jessenich91
ghcr_library := $(ghcr)/jessenich

labels = --label "maintainer=Jesse N. <jesse@keplerdev.com>" --label "org.opencontainers.image.source=https://github.com/jessenich/docker-syslog-ng"

semver_tag = v1.0.0
latest_tag = latest
platforms = linux/amd64, linux/arm64/v8, linux/arm/v7

get-docker-tag-args = source $(this_dir)makefile-support-functions.sh -g $(ghcr_library) -d $(dockerio_library) -l $(latest_tag) -s $(semver_tag); get-docker-tag-args -i $(1)

alpine-zsh-tags = $(shell $(call get-docker-tag-args,alpine-zsh))
docker-buildx-alpine-zsh = \
	docker buildx build -f $(images_root)/alpine-zsh/Dockerfile \
		$(tags) \
		$(labels) \
		--platform $(platforms) \
		--pull \
		--push \
		$(images_root)/alpine-zsh


.PHONY: build-azdeploy build-daemon build-postgres create-builder clean-builder login-dockerio login-ghcr build all
.PHONY: pull pull-postgres pull-daemon pull-azdeploy run-postgres run-daemon run-azdeploy compose-up compose-down

all: login create-builder build clean-builder pull

build: build-alpine-zsh
	$(info All builds completed successful)

login: login-dockerio login-ghcr

login-dockerio:
	$(info "Logging into to docker.io with username $(dockerio_username)")
	@docker login --username $(dockerio_username) --password $(dockerio_pat)

login-ghcr:
	$(info "Logging into to ghcr.io with username $(ghcr_username)")
	@docker login $(ghcr) --username $(ghcr_username) --password $(ghcr_pat)

create-builder:
	$(info "Creating BuildKit builder container...")
	$(shell docker buildx create --node "moby-builder-0" --platform $(platforms) --use)

clean-builder:
	$(info "Destroying syslog-ng-moby-builder-0")
	docker buildx rm --builder "moby-builder-0"

build-alpine-zsh:
	$(info "Building alpine-zsh image with tags: $(alpine-zsh-tags)")
	$(shell $(docker-buildx-alpine-zsh))
	$(info Finished building alpine-zsh image)

pull: pull-alpine-zsh

pull-alpine-zsh:
	$(info "Pulling jessenich91/syslog-ng-postgres:latest...")
	docker pull jessenich91/alpine-zsh:latest

run: run-alpine-zsh

run-alpine-zsh:
	docker run jessenich91/alpine-zsh:latest

# compose-up: pull
# 	docker-compose up -d

# compose-down:
# 	docker-compose down
