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



#!/bin/bash

# File path
SSHD_CONFIG="/etc/ssh/sshd_config"

# Output CSV header
echo "group,user"

# Extract all groups from AllowGroups line(s)
grep -i '^AllowGroups' "$SSHD_CONFIG" | while read -r line; do
    # Remove "AllowGroups" and split remaining into groups
    for group in $(echo "$line" | sed 's/^AllowGroups[ \t]*//'); do
        # Get group details using lsgroup
        group_info=$(lsgroup "$group" 2>/dev/null)

        # Check if lsgroup returned anything
        if [[ -n "$group_info" ]]; then
            # Extract USERS line
            users=$(echo "$group_info" | grep 'USERS' | sed 's/.*USERS:[ \t]*//')
            
            # Split users and print in CSV
            IFS=',' read -ra user_array <<< "$users"
            for user in "${user_array[@]}"; do
                echo "$group,$user"
            done
        fi
    done
done
