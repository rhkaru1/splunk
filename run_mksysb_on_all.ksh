#!/bin/bash
# Script to run mksysb.ksh on all servers listed in /local/aix_serverlist

# Read the list of servers from the file
SERVER_LIST="/local/aix_serverlist"

# Check if the server list file exists
if [ ! -f "$SERVER_LIST" ]; then
    echo "Error: Server list file not found at $SERVER_LIST"
    exit 1
fi

# Loop through each server in the list
while read -r server; do
    # Skip empty lines and lines starting with #
    if [[ -n "$server" && ! "$server" =~ ^# ]]; then
        echo "Running mksysb.ksh on $server..."
        ssh "$server" "/path/to/mksysb.ksh"
        if [ $? -eq 0 ]; then
            echo "mksysb.ksh completed successfully on $server."
        else
            echo "Error: mksysb.ksh failed on $server."
        fi
    fi
done < "$SERVER_LIST"

echo "Script finished."
