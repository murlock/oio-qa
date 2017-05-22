#!/usr/bin/env python
#
# check http://git.openstack.org/cgit/openstack/python-openstacksdk/tree/examples/compute/create.py
#

import os
import sys
from time import time

from openstack import connection, exceptions
from openstack import utils

utils.enable_logging(debug=False, stream=sys.stdout)

CONN = connection.Connection(auth_url=os.getenv("OS_AUTH_URL"),
                             project_name=os.getenv("OS_TENANT_NAME"),
                             username=os.getenv("OS_USERNAME"),
                             password=os.getenv("OS_PASSWORD"))

# for container in conn.object_store.containers():
#    print(container.name)

#for item in dir(conn):
#    print(str(item), type(item))

#print(conn.session.get_project_id())

SERVER_NAME = "test-michael"
VOLUME_NAME = "test-michael-vol"
IMAGE_NAME = "Ubuntu-16.04-amd64-20170330"
FLAVOR_NAME = "c1.m1.d1"
NETWORK_NAME = "private_network"
KEYPAIR_NAME = "mbonfils"

def retrieve_or_create_keypair(conn, name, create_if_missing=False):
    keypair = conn.compute.find_keypair(name)
    if not keypair:
        if not create_if_missing:
            raise ValueError("Missing Keypair %s" % name)
        raise Exception("TODO")
    return keypair


def create_server(conn):
    print("Create Server:")

    image = conn.compute.find_image(IMAGE_NAME)
    print(image)
    start = time()
    def create_volume():
        volume = conn.block_store.create_volume(name=VOLUME_NAME,
                                                image_id=image.id,
                                                volume_type="SSD",
                                                size="10",
                                                zone="nova")
        conn.block_store.wait_for_status(volume,
                                         status="available",
                                         failures=['error'],
                                         interval=2,
                                         wait=120)
        return volume

    try:
        # TODO: try to find from its name
        volume = conn.block_store.get_volume("020dc984-b2d9-4846-8e4c-25cf3259004e")
    except exceptions.NotFoundException:
        volume = create_volume()
    print("Volume is ready ! (%5.2f sec)" % (time() - start))

    flavor = conn.compute.find_flavor(FLAVOR_NAME)
    network = conn.network.find_network(NETWORK_NAME)
    keypair = retrieve_or_create_keypair(conn, name=KEYPAIR_NAME)


    def _create_server():
        # https://developer.rackspace.com/docs/cloud-servers/v2/extensions/ext-boot-from-volume/
        server = conn.compute.create_server(name=SERVER_NAME,
                                            #image_id=image.id, # OK but it use image
                                            block_device_mapping=[{
                                                'boot_index': 0,
                                                'uuid': volume.id,
                                                'source_type': 'volume',
                                                'destination_type': 'volume',
                                            }],
                                            flavor_id=flavor.id,
                                            networks=[{"uuid": network.id}],
                                            key_name=keypair.name)
        server = conn.compute.wait_for_server(server)
        return server

    start = time()
    try:
        server = conn.compute.find_server(SERVER_NAME, ignore_missing=False)
    except exceptions.ResourceNotFound:
        server = _create_server()
    print("Instance is ready ! (%5.2f sec)" % (time() - start))

    # retrieve available floating_ip

    server_ip = None
    for _ip in conn.network.ips(project_id=conn.session.get_project_id(), status='DOWN'):
        server_ip = _ip
        break

    conn.compute.add_floating_ip_to_server(server, server_ip.floating_ip_address)

    print("Instance is ready at %s with KEYPAIR %s" % (server_ip.floating_ip_address, KEYPAIR_NAME))

create_server(CONN)