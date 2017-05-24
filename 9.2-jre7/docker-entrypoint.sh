#!/bin/sh

set -e

if [ "$1" = jetty.sh ]; then
	if ! command -v bash >/dev/null 2>&1 ; then
		cat >&2 <<- 'EOWARN'
			********************************************************************
			ERROR: bash not found. Use of jetty.sh requires bash.
			********************************************************************
		EOWARN
		exit 1
	fi
	cat >&2 <<- 'EOWARN'
		********************************************************************
		WARNING: Use of jetty.sh from this image is deprecated and may
			 be removed at some point in the future.

			 See the documentation for guidance on extending this image:
			 https://github.com/docker-library/docs/tree/master/jetty
		********************************************************************
	EOWARN
fi

if ! command -v -- "$1" >/dev/null 2>&1 ; then
	set -- java -jar "$JETTY_HOME/start.jar" "$@"
fi

if [ -n "$TMPDIR" ] ; then
	case "$JAVA_OPTIONS" in
		*-Djava.io.tmpdir=*) ;;
		*) JAVA_OPTIONS="-Djava.io.tmpdir=$TMPDIR $JAVA_OPTIONS" ;;
	esac
fi

if [ "$1" = "java" -a -n "$JAVA_OPTIONS" ] ; then
	shift
	set -- java $JAVA_OPTIONS "$@"
fi

if expr "$*" : '^java .*/start\.jar.*$' >/dev/null ; then
	# this is a command to run jetty

	# check if it is a terminating command
	for A in "$@" ; do
		case $A in
			--add-to-start* |\
			--create-files |\
			--create-startd |\
			--download |\
			--dry-run |\
			--exec-print |\
			--help |\
			--info |\
			--list-all-modules |\
			--list-classpath |\
			--list-config |\
			--list-modules* |\
			--stop |\
			--update-ini |\
			--version |\
			-v )\
			# It is a terminating command, so exec directly
		        exec "$@"
		esac
	done

	if [ -f /jetty-quickstart -a /jetty-quickstart -nt $JETTY_BASE/start.d ] ; then
		set -- $(cat /jetty-quickstart)
	else
		# Do a jetty dry run to set the final command
		set -- $("$@" --dry-run)
	fi
fi

exec "$@"
