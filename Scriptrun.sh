#!/bin/bash

# Define the path to the servers list file
SERVERS_FILE="servers.list"
SCRIPT_PATH="/path/to/AIX.sh"

# Check if servers.list file exists
if [[ ! -f "$SERVERS_FILE" ]]; then
  echo "Servers list file not found: $SERVERS_FILE"
  exit 1
fi

# Loop through each server in the servers list
while IFS= read -r SERVER; do
  # Skip empty lines or comment lines
  if [[ -z "$SERVER" || "$SERVER" =~ ^# ]]; then
    continue
  fi
  
  echo "Running AIX.sh on $SERVER..."
  
  # Execute the script remotely on the server via SSH
  ssh "$SERVER" "bash -s" < "$SCRIPT_PATH"

  # Check if the script ran successfully
  if [[ $? -eq 0 ]]; then
    echo "AIX.sh executed successfully on $SERVER"
  else
    echo "Error running AIX.sh on $SERVER"
  fi
done < "$SERVERS_FILE"
