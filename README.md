# Makefile for docker images
Dockerfiles for wordpress in src/

Build image with `make`

Override the build options with `make BUILDOPTS="--OPTION_NAME=OPTION_VALUE"`

Change the default config with `make cnf="config_special.env" build`

Make options:
* help                           This help.
* build                          Build the container
* build-nc                       Build the container without caching
* run                            Run container with options in `$(cnf)`
* manifest                       Create and push manifest
* up                             Run container on port configured in `config.env` (Alias to run)
* stop                           Stop and remove a running container
* release                        Make a release by building and publishing the `{version}` and `latest` tagged containers to ECR
* publish                        Publish the `{version}` and `latest` tagged containers to ECR
* publish-latest                 Publish the `latest` tagged container to ECR
* publish-version                Publish the `{version}` tagged container to ECR
* tag                            Generate container tags for the `{version}` and `latest` tags
* tag-latest                     Generate container `{version}` tag
* tag-version                    Generate container `latest` tag
* version                        Output the current version
* app-name                       Output the repo and appname
