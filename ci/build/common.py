#!/usr/bin/env python

from __future__ import print_function
import os
import stat
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
    client.connect(ip, username=username, pkey=key)
    return client


def upload_file(client, filename, perm=0o0400):
    print("uploading", filename)
    sftp = client.open_sftp()
    fp = sftp.file(filename, mode='w')
    fp.write(open(filename).read())
    fp.close()

    sftp.chmod(filename, perm)
    sftp.close()
    print("success")

def download_directory(client, path, dest):
    sftp = client.open_sftp()

    def is_directory(path):
        try:
            return stat.S_ISDIR(sftp.stat(path).st_mode)
        except IOError:
             #Path does not exist, so by definition not a directory
            print("Testing invalid directory")
            return False

    def parse_directory(path, dest):
        item_list = sftp.listdir(path)
        dest = str(dest)

        if not os.path.isdir(dest):
            os.mkdir(dest)

        for item in item_list:
            item = str(item)

            if is_directory(path + "/" + item):
                parse_directory(path + "/" + item, dest + "/" + item)
            else:
                print("retrieve {0}/{1}".format(path, item))
                sftp.get(path + "/" + item, dest + "/" + item)

    parse_directory(path, dest)

def ssh_get_key(keystr, keypass=None):
    buf = StringIO(keystr)
    key = RSAKey.from_private_key(buf, password=keypass)
    return key
