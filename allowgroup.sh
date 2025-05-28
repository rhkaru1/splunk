#!/bin/bash

# Extract group names from AllowGroups line
groups=$(grep -i '^AllowGroups' /etc/ssh/sshd_config | awk '{$1=""; print $0}')

# Print CSV header
echo "user,group"

# Loop through each group and get users
for group in $groups; do
    users=$(lsgroup $group | awk -F= '/users/ {print $2}' | sed 's/,/ /g')
    for user in $users; do
        echo "$user,$group"
    done
done
