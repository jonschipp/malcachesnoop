#!/bin/bash
# BSD License: 
# Copyright (c) 2013, Jon Schipp
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this list of 
# conditions and the following disclaimer. Redistributions in binary form must reproduce
# the above copyright notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Check for argument
if [ -z "$1" ]; then
echo "Usage: $0 \$nameserverIP"
exit 1
fi

# Resolve and store target's name
ns=$(dig -x @$1 -x "$1" +short)

# d/l latest malware host list
curl --insecure -O https://secure.mayhemiclabs.com/malhosts/malhosts.txt &>/dev/null

# Initialize counter for array
n=1

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
