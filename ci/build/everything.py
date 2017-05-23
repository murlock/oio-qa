#!/usr/bin/env python


import time
import uuid

from common import remove_keypair

import create_vm
from prepare_vm import do_prepare
from run_vm import do_run


def run_job():
    # FIXME: should be PR name or git revision
    create_vm.SERVER_NAME = "{0}-{1}".format("master", str(uuid.uuid1()))
    create_vm.VOLUME_NAME = create_vm.SERVER_NAME + "-vol"
    create_vm.KEYPAIR_NAME = create_vm.SERVER_NAME + "-id"

    print("Create Instance")
    properties = create_vm.create_server(create_vm.CONN)

    print("key priv\n", properties['keypriv'])
    print("key pub\n", properties['keypub'])

    # TODO: ensure that Instance is started and available
    time.sleep(20)


    print("Prepare and build Docker template")
    do_prepare(properties['ip'],
               'ubuntu',
               properties['keypriv'])

    print("Launch test")
    do_run(properties['ip'],
           'ubuntu',
           properties['keypriv'])

    # TODO: retrieve artifacts here
    # and upload somewhere
    # should contains:
    # - outputs of everything we can
    # - outputs of tests (with ok/fail/skip, ...)

    if properties['keycreated']:
        print("Remove temporary key")
        remove_keypair(create_vm.CONN, properties['keyname'])

if __name__ == "__main__":
    run_job()
