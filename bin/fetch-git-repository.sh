#!/bin/bash
set -x
set -e

MODULE=$1 ; shift
URL=$1 ; shift

if [ $(ls -1U ${TMPDIR}/src/${MODULE} | wc -l) -le 0 ] ; then
	cd "${TMPDIR}/src"
	git clone "${URL}"
	cd "${TMPDIR}/src/${MODULE}"
else
	cd "${TMPDIR}/src/${MODULE}"
	git fetch --all
fi

