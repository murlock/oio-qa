#!/bin/bash

# Install any requirement file. That file is expected to be full of python
# modules, those will be installed in the current (virtual) environment.

set -e

D=$1 ; shift

install_file() {
	if [ -r "$1" ] ; then
		pip install -r "$1"
	fi
}

install_file "$D/requirements.txt"
install_file "$D/all-requirements.txt"
install_file "$D/test-requirements.txt"
