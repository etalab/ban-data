#!/bin/bash

echo "`date +%H:%M:%S` début de traitement"

# conversion/conformation/harmonisation en multi-thread des fichiers BAN en json pour addok
parallel -j 8 sh convert_ban2json.sh {} ::: 01 02 03 04 05 06 07 08 09 `seq 10 19` 2A 2B `seq 21 95` `seq 971 976`

echo "`date +%H:%M:%S` Fusion et compression des fichiers"
# fusion en un fichier unique
: > ../out/ban-odbl.json
for dep in {01..19} 2A 2B {21..95} {971..974} ; do echo $dep; grep -v ^$ ../out/ban-odbl-$dep.json >>  ../out/ban-odbl.json ; gzip -9 ban-odbl-$dep.json ; done

echo "`date +%H:%M:%S` fin de traitement"
