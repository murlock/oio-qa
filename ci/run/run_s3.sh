#!/bin/bash

# we suppose that a docker image with name `git` already exists
# check https://github.com/murlock/dockerfiles to build it


# FIXME: manage properly options

# if set, it assume that a docker image is already running
SKIP_DOCKER=$1
DOCKER_TAG=latest

set -e
set -x

function start_docker() {
    local TEST=$1

    if [ ! -z $SKIP_DOCKER ]; then
        return
    fi

    docker rm test_s3 || true
    # FIXME we should use docker run -d and use --log-driver
    docker run -p 127.0.0.1:5000:5000 --name test_s3 sds-source:${DOCKER_TAG} >output_$TEST.log 2>&1 &

    # FIXME we should test availability of port 5000 instead of this hack
    echo -n "Init "
    for i in $(seq 20); do
        echo -n .
        sleep 1
    done
}

function stop_docker() {
    if [ ! -z $SKIP_DOCKER ]; then
        return
    fi
    docker stop test_s3
}

function run_s3cmd() {
    start_docker s3cmd
    if [ ! -d s3cmd ]; then
        git clone https://github.com/s3tools/s3cmd
        cd s3cmd
        git checkout 596bbe83a7d31bb4a762f18bbee4f8561bae813e
        # don't stop at first error and remove specific test regarding case
        patch -p1 -i ../s3cmd.diff
    else
        cd s3cmd
    fi

    ./run-tests.py --config ../s3cfg_port_5000 | tee ../test_s3cmd.log
    stop_docker
    cd ..
}

function run_s3ceph() {
    start_docker s3ceph

    if [ ! -d s3-tests ]; then
        git clone https://github.com/ceph/s3-tests.git
        cd s3-tests
        git checkout 77241f587f1cb7fb8860546ea9cda93637ce57a8
    else
        cd s3-tests
    fi

    ./bootstrap
    S3TEST_CONF=../ceph-s3.cfg ./virtualenv/bin/nosetests -v 2>&1 | tee ../test_s3ceph.log | grep -Eb1 'ok|FAIL|ERROR|SKIP' | ../color.sh

    stop_docker
}


run_s3ceph
run_s3cmd
