#!/bin/bash

# Input and output files
SERVER_LIST="serverlist.txt"
OUTPUT_FILE="information.csv"

# Write CSV header
echo "Server,OS Version" > "$OUTPUT_FILE"

# Read server list into array
readarray -t SERVERS < "$SERVER_LIST"

# Loop through each server using a for loop
for SERVER in "${SERVERS[@]}"; do
    if [[ -n "$SERVER" ]]; then
        # Get the OS version using ssh
        OS_VERSION=$(ssh -o ConnectTimeout=5 "$SERVER" "cat /etc/redhat-release" 2>/dev/null)

        # Handle connection errors
        if [[ -z "$OS_VERSION" ]]; then
            OS_VERSION="Unable to retrieve"
        fi

        # Append to CSV
        echo "$SERVER,\"$OS_VERSION\"" >> "$OUTPUT_FILE"
    fi
done

echo "OS version information saved to $OUTPUT_FILE"
