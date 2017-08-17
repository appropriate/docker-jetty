#!/bin/sh
rm -f /jetty-start
/docker-entrypoint.sh --dry-run | sed 's/\\$//' > /jetty-start
