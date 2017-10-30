#!/bin/bash

# we suppose that a docker image with name `sds-source` already exists

# if set, it assume that a docker image is already running
SKIP_DOCKER=$1
DOCKER_TAG=latest
OUTPUT_RESULT=$HOME/output

OUTPUT_CUR_TEST=
set -e
set -x

function init() {
    local TEST=$1

    OUTPUT_CUR_TEST=${OUTPUT_RESULT}/${TEST}
    mkdir -p ${OUTPUT_CUR_TEST}
}

function run_oiofs_pjdfstest() {
    init oiofs_pjdfstest
    $HOME/oio-fs/docker/run.sh
}


run_oiofs_pjdfstest
