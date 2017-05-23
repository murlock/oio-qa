#!/usr/bin/env python

from __future__ import print_function
try:
    import cStringIO as StringIO
except:
    from io import StringIO

from paramiko import SSHClient, RSAKey, AutoAddPolicy

def retrieve_or_create_keypair(conn, name, create_if_missing=False):
    keypair = conn.compute.find_keypair(name, ignore_missing=True)
    if keypair:
        return (keypair, False)

    if not create_if_missing:
        raise ValueError("Missing Keypair %s" % name)
    keypair = conn.compute.create_keypair(name=name)
    return (keypair, True)

def remove_keypair(conn, name):
    conn.compute.delete_keypair(name, ignore_missing=True)

def ssh_connect(ip, username, key):
    client = SSHClient()
    client.set_missing_host_key_policy(AutoAddPolicy())
    client.connect(ip, username='ubuntu', pkey=key)
    return client


def upload_file(client, filename, perm=0o0400):
    print("uploading", filename)
    sftp = client.open_sftp()
    fp = sftp.file(filename, mode='w')
    fp.write(open(filename).read())
    fp.close()

    sftp.chmod(filename, 0o0777)
    sftp.close()
    print("success")

def ssh_get_key(keystr, keypass=None):
    buf = StringIO(keystr)
    key = RSAKey.from_private_key(buf, password=keypass)
    return key
