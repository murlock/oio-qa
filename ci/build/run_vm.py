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
    client.connect(ip, username='ubuntu', pkey=key)
    return client

def do_run(ip, username, keyfile, keypass):
    key = RSAKey.from_private_key_file(keyfile, password=keypass)

    client = do_connect(ip, username, key)

    # upload minimal requirements stuff
    upload_file(client, 'run.sh',  0o0555) # FIXME: use proper perms

    (stdin, stdout, stderr) = client.exec_command('./run.sh', get_pty=True)

    for line in stdout:
        print(line, end="")

if __name__ == "__main__":
    ip = sys.argv[1]
    username = sys.argv[2]
    keyfile = sys.argv[3]
    if len(sys.argv) >= 5:
        keypass = sys.argv[4]
    else:
        keypass = None
    do_run(ip, username, keyfile, keypass)
