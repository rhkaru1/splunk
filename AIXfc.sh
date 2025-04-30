#!/bin/ksh

hostname=$(hostname)
echo "Server,Adapter,WWPN,Z9,FRU,Customer_Card"

for fcs in $(lsdev -Cc adapter | grep fcs | awk '{print $1}')
do
    # Get WWPN
    wwpn=$(lsattr -El $fcs -a netaddr | awk '{print $2}')
    
    # Get Z9 (Serial Number)
    z9=$(lscfg -vl $fcs | grep -i "Serial Number" | awk -F. '{print $2}' | sed 's/^[ \t]*//')
    
    # Get FRU
    fru=$(lscfg -vl $fcs | grep -i "Part Number" | awk -F. '{print $2}' | sed 's/^[ \t]*//')
    
    # Get Customer Card (Location Code)
    cust_card=$(lscfg -vl $fcs | grep -i "Location" | awk -F. '{print $2}' | sed 's/^[ \t]*//')
    
    echo "$hostname,$fcs,$wwpn,$z9,$fru,$cust_card"
done
