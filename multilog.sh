#!/bin/bash

# --- CONFIGURATION ---
Folder="${1:-logFolder}"
count="${2:-10}"
MEMORY="${3:-850MB}"
MEMORY_SWAP="${4:-3G}"
# ---------------------
mkdir $Folder

for i in $(seq $count); do
echo "./Folder/$i-log";
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
    ./sublog.sh $DOCKER_NAME "./$Folder/$i-stats" &
    echo "Logger started"
    docker exec $DOCKER_NAME ninja what-to-build >> "$LOG_FILE"
    echo "linking finished"
    docker stop $DOCKER_NAME >> /dev/null
    docker rm $DOCKER_NAME >> /dev/null
    echo "docker removed"
done
