#!/usr/bin/env python

from __future__ import print_function
import sys

from paramiko import SSHClient, RSAKey, AutoAddPolicy


def upload_file(client, filename, perm=0o0400):
    print("uploading", filename)
    sftp = client.open_sftp()
    fp = sftp.file(filename, mode='w')
    fp.write(open(filename).read())
    fp.close()

    sftp.chmod(filename, 0o0777)
    sftp.close()
    print("success")

def do_connect(ip, username, key):
    client = SSHClient()
    client.set_missing_host_key_policy(AutoAddPolicy())
    client.connect('192.168.1.106', username='ubuntu', pkey=key)
    return client

def do_prepare(ip, username, keyfile, keypass):
    key = RSAKey.from_private_key_file(keyfile, password=keypass)

    client = do_connect(ip, username, key)

    # upload minimal requirements stuff
    upload_file(client, 'install.sh',  0o0555) # FIXME: use proper perms

    # install Docker
    print("install docker")
    (stdin, stdout, stderr) = client.exec_command('./install.sh')
    print(stdout.read())
    print("done")
    client.close()


    # close and reopen connection to refresh ID and Groups
    client = do_connect('192.168.1.106', username='ubuntu', key=key)

    upload_file(client, 'build.sh', 0o0555)
    print("build docker image")
    (stdin, stdout, stderr) = client.exec_command('./build.sh')

    print(stdout.read())

if __name__ == "__main__":
    ip = sys.argv[1]
    username = sys.argv[2]
    keyfile = sys.argv[3]
    if len(sys.argv) >= 5:
        keypass = sys.argv[4]
    else:
        keypass = None
    do_prepare(ip, username, keyfile, keypass)
