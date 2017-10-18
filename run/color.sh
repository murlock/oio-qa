#!/bin/bash

RED=$(printf "\033[31m")
GREEN=$(printf "\033[32m")
RESET=$(printf "\033[0m")

sed -e "s/^\(.*ok\)$/${GREEN}\1${RESET}/g" \
    -e "s/^\(.*FAIL\)$/${RED}\1${RESET}/g" \
    -e "s/^\(.*ERROR\)$/${RED}\1${RESET}/g"

