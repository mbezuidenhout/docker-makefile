# Makefile for docker images

# Build options
# You can override the build options with `make BUILDOPTS="--OPTION_NAME=OPTION_VALUE
BUILDOPTS ?= '--pull'

# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# grep the version from the mix file
VERSION=$(shell uname -m)
ifeq ($(VERSION),x86_64)
	VERSION=amd64
endif
ifneq (,$(findstring arm,$(VERSION)))
	VERSION=arm
endif

# Get the app name from the current directory and parent directory
PWD=$(shell pwd)
DOCKER_REPO=$(shell basename $(shell dirname ${PWD}))
APP_NAME=$(shell basename ${PWD})

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := build


# DOCKER TASKS
# Build the container
build: ## Build the container
	docker build -t $(APP_NAME) $(BUILDOPTS) ./src

build-nc: ## Build the container without caching
	docker build --no-cache -t $(APP_NAME) ./src

run: ## Run container with options in `$(cnf)`
	docker run -ti --rm --env-file=$(cnf) --name="$(APP_NAME)" $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

manifest: ## Create and push manifest
	docker manifest create $(DOCKER_REPO)/$(APP_NAME):latest $(DOCKER_REPO)/$(APP_NAME):amd64 $(DOCKER_REPO)/$(APP_NAME):arm
	docker manifest --purge $(DOCKER_REPO)/$(APP_NAME):latest

up: build run ## Run container on port configured in `config.env` (Alias to run)

stop: ## Stop and remove a running container
	docker stop $(APP_NAME); docker rm $(APP_NAME)

release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers to ECR

# Docker publish
publish: repo-login publish-latest publish-version ## Publish the `{version}` ans `latest` tagged containers to ECR

publish-latest: tag-latest ## Publish the `latest` taged container to ECR
	@echo 'publish latest to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):latest

publish-version: tag-version ## Publish the `{version}` taged container to ECR
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

# Docker tagging
tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

tag-latest: ## Generate container `{version}` tag
	@echo 'create tag latest'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo 'create tag $(VERSION)'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

version: ## Output the current version
	@echo $(VERSION)

app-name: ## Output the repo and appname
	@echo $(DOCKER_REPO)/$(APP_NAME):$(VERSION)
