#!/bin/bash


PORT=8888


for IMAGE in jetty:9.4-jre8 jetty:9.4-jre8-alpine jetty:9.3-jre8 jetty:9.4-jre8-alpine jetty:9.2-jre8 jetty:9.2-jre7
do
  echo -n "$IMAGE = "
  docker run --rm $IMAGE --version | egrep lib/jetty-server | sed 's/.*: *\([^ ]*\) |.*$/\1/'

  INSTANCE=$(docker run -d -p 127.0.0.1:$PORT:8080 -v $PWD/quick-test:/var/lib/jetty/webapps/quick-test $IMAGE)
  until curl http://127.0.01:$PORT/quick-test/ 2>/dev/null ; do sleep 0.5 ; done
  docker kill $INSTANCE >/dev/null

done

