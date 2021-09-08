#!/bin/sh

# check clamad using localhost 3310 (tcp port)
if [ "$(echo PING | nc localhost 3310)" = "PONG" ]; then
    echo "clamad is alive!"
else
    echo 1>&2 "clamad healthcheck failed :'("
    exit 1
fi
