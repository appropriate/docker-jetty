#!/bin/sh

rm -f $JETTY_BASE/jetty.start
/docker-entrypoint.sh --dry-run | sed 's/\\$//' > $JETTY_BASE/jetty.start
