#!/bin/bash

# Output CSV header
echo "Server,CPUs,Memory,HyperThreading" > output.csv

# Read servers from file into array
servers=($(cat serverlist.txt))

# Loop over each server
for server in "${servers[@]}"; do
  echo "Processing $server..."

  output=$(ssh -o ConnectTimeout=10 "$server" bash << 'EOF'
    cpus=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
    mem_total=$(free -h | awk '/^Mem:/ {print $2}')
    
    if [ -f /sys/devices/system/cpu/smt/active ]; then
      smt_active=$(cat /sys/devices/system/cpu/smt/active)
      if [ "$smt_active" -eq 1 ]; then
        ht_status="Enabled"
      else
        ht_status="Disabled"
      fi
    else
      ht_status="Unknown"
    fi

    echo "$cpus,$mem_total,$ht_status"
EOF
  )

  if [ -z "$output" ]; then
    echo "$server,ERROR,ERROR,ERROR" >> output.csv
  else
    echo "$server,$output" >> output.csv
  fi
done

echo "Done. Results saved to output.csv"
