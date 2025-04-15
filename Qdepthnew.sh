#!/bin/ksh

# File containing list of AIX server hostnames or IPs
SERVER_LIST="serverlist.txt"
OUTPUT_FILE="queue_depth_report.csv"

# Write CSV header
echo "Server,Disk,Queue_Depth" > "$OUTPUT_FILE"

# Loop through each server
while IFS= read -r server; do
    echo "Processing $server..."
    ssh "$server" '
        for disk in $(lsdev -Cc disk | awk '"'"'{print $1}'"'"'); do
            queue_depth=$(lsattr -El $disk -a queue_depth -F value 2>/dev/null)
            if [ -n "$queue_depth" ]; then
                echo "'"$server"',$disk,$queue_depth"
            fi
        done
    ' >> "$OUTPUT_FILE"
done < "$SERVER_LIST"

echo "Done! Output saved to $OUTPUT_FILE"
