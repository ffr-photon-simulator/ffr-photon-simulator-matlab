#!/usr/bin/env bash

# Usage:
# [user@linux] $ coeff=0.6; photons=(l4 l3 l2 10); ./handler.sh "${photons[@]}" viral-data.csv photon-data.csv $coeff
#
# This will give you the number of viruses remaining for each photon amount in the photons array.

declare -a photons=($1 $2 $3 $4)

for n in "${photons[@]}"; do
    ./viruses-remaining.py $5 $6 $7 $8 --scaled $n
done
