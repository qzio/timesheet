#!/bin/bash

PIDFILE=$(dirname $0)/../data/ts.pid
HOST=127.0.0.1
PORT=1337
RACK_ENV="production"


case "$1" in
  start)
    echo "Start tracking"
    curl -X POST -F "cmd=start" $HOST:$PORT/timer.json
    ;;
  stop)
    echo "Stop tracking"
    curl -X POST -F "cmd=stop" -F "comment=$2" $HOST:$PORT/timer.json
    ;;
  status)
    echo "Check status"
    curl -X GET $HOST:$PORT/index.txt
    ;;
  startd)
    echo "Starting daemon"
    rackup -D -o $HOST -p $PORT -P $PIDFILE $(dirname $0)/../config.ru #&> $(dirname $0)/../data/production.log &
    ;;
  stopd)
    echo "stopping daemon"
    if [ -e $PIDFILE ]; then
      kill `cat $PIDFILE`
      rm $PIDFILE
    else
      echo "Did not find a PID file, unable to stop daemon"
    fi
    ;;
  restartd)
    echo "Restarting daemon"
    $0 stopd
    $0 startd
    ;;
  *)
    echo "USAGE: $0 start|stop|startd|stopd"
    exit 1
    ;;
esac
exit 0;
