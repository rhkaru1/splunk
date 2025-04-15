#!/bin/ksh

echo "Disk\t\tQueue Depth"
echo "-----------------------------"

for disk in $(lsdev -Cc disk | awk '{print $1}'); do
    queue_depth=$(lsattr -El $disk -a queue_depth -F value 2>/dev/null)
    if [ -n "$queue_depth" ]; then
        printf "%-16s %s\n" "$disk" "$queue_depth"
    fi
done
