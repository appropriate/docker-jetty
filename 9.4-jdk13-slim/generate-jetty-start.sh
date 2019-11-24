#!/bin/sh

if [ -z "$JETTY_START" ] ; then
	JETTY_START=$JETTY_BASE/jetty.start
fi
rm -f $JETTY_START
/docker-entrypoint.sh --dry-run | sed -e 's/ -Djava.io.tmpdir=[^ ]*//g' -e 's/\\$//' > $JETTY_START
