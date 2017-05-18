#!/bin/bash

set -e

if [ "$1" = jetty.sh ]; then
	cat >&2 <<- 'EOWARN'
		********************************************************************
		WARNING: Use of jetty.sh from this image is deprecated and may
			 be removed at some point in the future.

			 See the documentation for guidance on extending this image:
			 https://github.com/docker-library/docs/tree/master/jetty
		********************************************************************
	EOWARN
fi

if ! type -- "$1" &>/dev/null; then
	set -- java -jar "-Djava.io.tmpdir=$TMPDIR" "$JETTY_HOME/start.jar" "$@"
fi

exec "$@"
