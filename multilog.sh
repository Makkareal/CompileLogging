#!/bin/bash

# --- CONFIGURATION ---
STATS_FILE="${1:-build_stats.csv}"
LOG_FILE="${2:-compilation.log}"
count="${3:-10}"
MEMORY="${4:-850MB}"
MEMORY_SWAP="${5:-3G}"
# ---------------------
for i in $(seq $count); do
  DOCKER_ID=$(
  docker run -i -d\
    --memory="$MEMORY"\
    --memory-swap="$MEMORY_SWAP"\
    -v /path/to/llvm:/path/to/llvm \
    -w path/to/build/folder \
    llvm-arch-builder
    )
  DOCKER_NAME=$(docker inspect --format="{{.Name}}" $DOCKER_ID)
    docker exec $DOCKER_NAME rm ./bin/binary-to-remove
    echo "Removed binary"
    ./sublog.sh $DOCKER_NAME "$STATS_FILE" &
    echo "Logger started"
    docker exec $DOCKER_NAME ninja what-to-build >> "$LOG_FILE"
    echo "linking finished"
    docker stop $DOCKER_NAME >> /dev/null
    docker rm $DOCKER_NAME >> /dev/null
    echo "" >>$STATS_FILE
    echo "" >>$STATS_FILE
    echo "" >>$STATS_FILE
    echo "docker removed"
done
