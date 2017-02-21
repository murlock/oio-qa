#!/usr/bin/env bash
set -x
set -e

COMPONENTS=$1 ; shift
RELEASE=$1 ; shift

if [ -z "$TMPDIR" ] ; then
	echo "TMPDIR must be defined in the environment"
	exit 1
fi

cd "$TMPDIR"
source "$COMPONENTS"
source "$RELEASE"
source "$HOME/.python/env/bin/activate"

puppet apply $HOME/oio-qa/config/single.pp

