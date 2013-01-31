#!/bin/bash
# malcachesnoop.sh

# Check for argument
if [ -z "$1" ]; then
echo "Usage: $0 \$nameserverIP"
exit 1
fi

# Resolve and store target's name
ns=$(dig -x @$1 -x "$1" +short)

# d/l latest malware host list
curl -O https://secure.mayhemiclabs.com/malhosts/malhosts.txt &>/dev/null

# Initialize counter for array
n=1
i

# Begin loop to read in file
while read name
do

# Look up each item in malhosts.txt and store it in an array
ipdb[$n]=$(dig @$1 "$name" +norecurse +short | head -1)

# if index of item contains a DNS name, do a reverse lookup and move on to next index
	if [ ! -z "${ipdb[$n]}" ]; then
	namedb[$n]=$(dig @$1 -x $(echo ${ipdb[$n]}) +short)
	n=$(($n+1))
	fi

# malhosts.txt is read in here
done < <(cut -f1 < malhosts.txt | sed -e '/^#/d' -e '/^$/d')

# Count indexes with names 
found=$(echo $((${#ipdb[@]}-1)))

# Print heading
echo -e "\n[*] Results - host [ 'IP Address' = 'DNS Name' ] is in the cache\n"

# Go through each found item and print the IP and DNS name, if available
for ((i = 1; i <= $found; i++ ))
do
echo "[+] Found - host ['${ipdb[$i]}']:['${namedb[$i]:--Unable to
Resolve-}'] is in the cache"
done

# Count total lines with names in malhosts.txt
total=$(cut -f1 < malhosts.txt | sed -e '/^#/d' -e '/^$/d' | wc -l)

# Print footer w/stats
echo -e "--\n[=] $found of $total entries have been discovered in
${ns}'s cache\n"
