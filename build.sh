#!/usr/bin/env bash

# build routine Docker image, should be called 
# from the root of the repo to work properly

# check if Docker is present
if [ -x "$(command -v docker)" ]; then
    echo "Found Docker... preparing container"
    docker build -t jh-da .
else
    echo "Please install Docker: https://docs.docker.com/install/"
fi


