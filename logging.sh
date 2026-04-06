#!/bin/bash

# --- CONFIGURATION ---
CONTAINER_NAME="comp-docker"
STATS_FILE="${1:-build_stats.csv}"
LOG_FILE="${2:-compilation.log}"
# ---------------------

cleanup() {
    echo -e "\n[Monitor] Ninja finished or script interrupted. Cleaning up..."
    [[ -n $MONITOR_PID ]] && kill $MONITOR_PID 2>/dev/null
    [[ -n $LOG_PID ]] && kill $LOG_PID 2>/dev/null
    pkill -P $$ 2>/dev/null
    exit
}

trap cleanup SIGINT SIGTERM

if ! docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    echo "Error: Container '$CONTAINER_NAME' not found."
    exit 1
fi

echo "Waiting for 'ninja' to start..."
while ! docker exec "$CONTAINER_NAME" pgrep -x "ninja" > /dev/null 2>&1; do
    sleep 0.5
done

NINJA_PID=$(docker exec "$CONTAINER_NAME" pgrep -x "ninja")
echo "Ninja detected (PID: $NINJA_PID). Monitoring..."


START_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)


echo "Timestamp,RAM_Usage,Swap_Usage,CPU_Perc" > "$STATS_FILE"
(
    while docker exec "$CONTAINER_NAME" ps -p "$NINJA_PID" > /dev/null 2>&1; do
        RAM_B=$(docker exec "$CONTAINER_NAME" cat /sys/fs/cgroup/memory.current 2>/dev/null)
        SWP_B=$(docker exec "$CONTAINER_NAME" cat /sys/fs/cgroup/memory.swap.current 2>/dev/null)
        RAM_MAX=$(docker exec "$CONTAINER_NAME" cat /sys/fs/cgroup/memory.max 2>/dev/null)
        SWP_MAX=$(docker exec "$CONTAINER_NAME" cat /sys/fs/cgroup/memory.swap.max 2>/dev/null)

        if [[ "$RAM_MAX" == "max" ]]; then RAM_MAX=$(free -b | grep Mem | awk '{print $2}'); fi
        if [[ "$SWP_MAX" == "max" ]]; then SWP_MAX=$(free -b | grep Swap | awk '{print $2}'); fi

        RAM_PERC=$(echo "scale=2; ($RAM_B / $RAM_MAX) * 100" | bc)
        SWP_PERC=$(echo "scale=2; ($SWP_B / $SWP_MAX) * 100" | bc)
        CPU=$(docker stats --no-stream --format "{{.CPUPerc}}" "$CONTAINER_NAME")

        echo "$(date '+%H:%M:%S'),$((RAM_B/1048576))MiB ($RAM_PERC%),$((SWP_B/1048576))MiB ($SWP_PERC%),$CPU" >> "$STATS_FILE"
        sleep 1
    done
) &
MONITOR_PID=$!



docker logs -f --since "$START_TIME" "$CONTAINER_NAME" | tee -a "$LOG_FILE" &
LOG_PID=$!


while docker exec "$CONTAINER_NAME" ps -p "$NINJA_PID" > /dev/null 2>&1; do
    sleep 1
done

cleanup
