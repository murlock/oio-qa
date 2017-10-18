#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

# for s3cmd
# FIXME: use dnsmasq to hide this
echo "127.0.0.1 ubuntu-s3cmd-autotest-1.localhost ubuntu-s3cmd-autotest-2.localhost ubuntu-s3cmd-autotest-3.localhost" | sudo tee -a /etc/hosts
# for s3ceph
unset LC_ADDRESS  LC_IDENTIFICATION  LC_MEASUREMENT  LC_MONETARY  LC_NAME  LC_NUMERIC  LC_PAPER  LC_TELEPHONE  LC_TIME


for i in run_*; do
    ./$i
done
