#!/usr/bin/env bash
set -m

echo "[init] Download initial Clam database. This process might take a few minutes!"
/usr/bin/freshclam

echo "[service] Starting freshclam and clam services..."
# start services
freshclam -d &
clamd &

# check PIDs for gracefully shutdown
pids=$(jobs -p)

# service exit var
svc_exit=0

function gracefullyShutdown() {
    trap "" SIGINT

    echo "[service] Stoping service gracefully..."

    for pid in $pids; do
        if ! kill -0 "$pid" 2> /dev/null; then
            wait "$pid"
            svc_exit=$?
        fi
    done

    kill "$pids" 2> /dev/null
}

# run gracefullyShutdown
trap gracefullyShutdown SIGINT
wait -n

exit $svc_exit
