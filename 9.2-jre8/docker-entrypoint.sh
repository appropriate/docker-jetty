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

if [ -z "$TMPDIR" ] ; then
	TMPDIR=/tmp/jetty
	mkdir $TMPDIR 2>/dev/null
fi
case "$JAVA_OPTIONS" in
	*-Djava.io.tmpdir=*) ;;
	*) JAVA_OPTIONS="-Djava.io.tmpdir=$TMPDIR $JAVA_OPTIONS" ;;
esac

if expr "$*" : 'java .*/start\.jar.*$' >/dev/null ; then
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

	if [ $(whoami) != "jetty" ]; then
		cat >&2 <<- EOWARN
			********************************************************************
			WARNING: User is $(whoami)
			         The user should be (re)set to 'jetty' in the Dockerfile
			********************************************************************
		EOWARN
	fi

	if [ -f $JETTY_BASE/jetty.start ] ; then
		if [ $JETTY_BASE/start.d -nt $JETTY_BASE/jetty.start ] ; then
			cat >&2 <<- 'EOWARN'
			********************************************************************
			WARNING: The $JETTY_BASE/start.d directory has been modified since
			         the $JETTY_BASE/jetty.start files was generated. Either delete 
			         the $JETTY_BASE/jetty.start file or re-run 
				     /generate-jetty.start.sh 
			         from a Dockerfile
			********************************************************************
			EOWARN
		fi
		echo $(date +'%Y-%m-%d %H:%M:%S.000'):INFO:docker-entrypoint:jetty start command from \$JETTY_BASE/jetty.start
		set -- $(cat $JETTY_BASE/jetty.start)
	else
		# Do a jetty dry run to set the final command
		"$@" --dry-run > $JETTY_BASE/jetty.start
		if [ $(egrep -v '\\$' $JETTY_BASE/jetty.start | wc -l ) -gt 1 ] ; then
			# command was more than a dry-run
			cat $JETTY_BASE/jetty.start \
			| awk '/\\$/ { printf "%s", substr($0, 1, length($0)-1); next } 1' \
			| egrep -v '[^ ]*java .* org\.eclipse\.jetty\.xml\.XmlConfiguration '
			exit
		fi
		set -- $(sed 's/\\$//' $JETTY_BASE/jetty.start)
	fi
fi

if [ "${1##*/}" = java -a -n "$JAVA_OPTIONS" ] ; then
	java="$1"
	shift
	set -- "$java" $JAVA_OPTIONS "$@"
fi

exec "$@"
