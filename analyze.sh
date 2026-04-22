#!/bin/bash

SEARCH_DIR="${1:-folder}"
GENERATE_GRAPHS="${2:-false}"

TEMP_FILE=$(mktemp)
OUTPUT_FILE="$SEARCH_DIR"/result.txt
echo -e "Run Times" > "$OUTPUT_FILE"
#Find stat files
for stats_file in "$SEARCH_DIR"/[0-9]*-stats; do
    log_file="${stats_file%-stats}-log"
    if [ -f "$log_file" ]; then
        # If the run was not failed include in statistics
        if ! grep -qi "failed" "$log_file"; then

            # Calculate duration
            duration=$(awk -F';' '
                NR > 1 && $1 ~ /^[0-9]{2}:[0-9]{2}:[0-9]{2}$/ {
                    split($1, a, ":")
                    sec = a[1]*3600 + a[2]*60 + a[3]
                    if (first == "") first = sec
                    last = sec
                }
                END { if (first != "") print last - first }
            ' "$stats_file")

            if [ ! -z "$duration" ]; then
                echo "$duration" >> "$TEMP_FILE"
                echo "$(basename "$stats_file"): ${duration}s" >> "$OUTPUT_FILE"

                if [ "$GENERATE_GRAPHS" = true ]; then
                    graph_out="${stats_file}.png"

                    gnuplot -e '
                    set terminal png size 800,400;
                    set datafile separator ";";
                    set datafile columnhead;
                    set timefmt "%H:%M:%S";
                    start = 0;
                    elapsed(x) = (start == 0 ? (start = x, 0) : x - start);

                    set output "'"$graph_out"'";
                    set title "Resource Usage: '"$(basename "$stats_file")"'";
                    set xlabel "Seconds elapsed";
                    set ylabel "RAM + Swap Usage";
                    plot "'"$stats_file"'" using (elapsed(timecolumn(1))):($2+$4) with lines title "RAM+Swap" lc rgb "blue";
    '
                fi
            fi
        fi
    fi
done

# Calculate Average and Median
echo -e "Statistics" >> "$OUTPUT_FILE"
sort -n "$TEMP_FILE" | awk -v out="$OUTPUT_FILE" '
    {
        count++
        sum += $1
        arr[count] = $1
    }
    END {
        avg = sum / count

        for (i = 1; i <= count; i++) {
            sq_diff_sum += (arr[i] - avg)^2
        }

        std_dev = sqrt(sq_diff_sum / count)

        if (count % 2 == 1) {
            median = arr[(count + 1) / 2]
        } else {
            median = (arr[count / 2] + arr[count / 2 + 1]) / 2
        }


        printf "Files Analyzed: %d\n", count >> out
        printf "Average Time:   %.2f seconds\n", avg >> out
        printf "Median Time:    %.2f seconds\n", median >> out
        printf "Standard Deviation: %.2f \n", std_dev >> out

    }
'
rm "$TEMP_FILE"
echo -e "\nResults saved to: $OUTPUT_FILE"
