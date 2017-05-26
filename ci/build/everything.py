#!/usr/bin/env python


import tempfile
import time
import uuid

from common import remove_keypair, download_directory
from common import ssh_connect, ssh_get_key, upload_result

import create_vm
from prepare_vm import do_prepare
from run_vm import do_run
from html import create_html_report


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

    tmpdir = tempfile.mkdtemp()

    # download artifacts
    key = ssh_get_key(properties['keypriv'])
    client = ssh_connect(properties['ip'], 'ubuntu', key)
    download_directory(client, "output/", tmpdir)
    # build webpage
    create_html_report(tmpdir)

    # and upload somewhere
    # TODO: include properies like branch/tag/commit id/PR/time consumed
    upload_result(tmpdir, os.getenv('RESULT_UPLOAD_URL'))

    # remove tmpdir
    shutil.rmtree(tmpdir)

    if properties['keycreated']:
        remove_keypair(create_vm.CONN, properties['keyname'])

    create_vm.delete_server(create_vm.CONN, properties['server_id'])

if __name__ == "__main__":
    run_job()
