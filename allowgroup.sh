#!/bin/bash

# Extract groups from AllowGroups line
groups=$(grep -i '^AllowGroups' /etc/ssh/sshd_config | awk '{$1=""; print $0}')

# CSV header
echo "user,group"

# Loop through each group
for group in $groups; do
    # Extract users from lsgroup output (handle multi-line format)
    users=$(lsgroup $group | awk -F= '/users/ {gsub(",", " "); print $2}')
    
    # Print user,group lines
    for user in $users; do
        echo "$user,$group"
    done
done
