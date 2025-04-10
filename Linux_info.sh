#!/bin/bash

# Output CSV header
echo "Server,CPUs,Memory_MB,HyperThreading" > output.csv

# Read servers from file into array
servers=($(cat serverlist.txt))

# Loop over each server
for server in "${servers[@]}"; do
  echo "Processing $server..."

  output=$(ssh "$server" bash << 'EOF'
    cpus=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
    cores=$(lscpu | grep "^Core(s) per socket:" | awk '{print $4}')
    sockets=$(lscpu | grep "^Socket(s):" | awk '{print $2}')
    mem_total=$(free -m | awk '/^Mem:/ {print $2}')
    
    ht_status="Disabled"
    if [ "$cpus" -gt $((cores * sockets)) ]; then
      ht_status="Enabled"
    fi

    echo "$cpus,$mem_total,$ht_status"
EOF
  )

  echo "$server,$output" >> output.csv
done

echo "Done. Results saved to output.csv"
