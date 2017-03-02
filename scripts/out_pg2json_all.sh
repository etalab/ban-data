#!/bin/bash

echo "`date +%H:%M:%S` Export JSON global"

echo '' > ../out/ban-odbl.json

# conversion/conformation/harmonisation en multi-thread des fichiers BAN en json pour addok
parallel -j 1 sh out_pg2json.sh $1 >> ../out/ban-odbl.json {} ::: 01 02 03 04 05 06 07 08 09 `seq 10 19` 2A 2B `seq 21 95` `seq 971 974` 976

echo "`date +%H:%M:%S` Compression fichier global"
# compression et copie sur le site web
gzip -9 ban-odbl.json

echo "`date +%H:%M:%S` fin de traitement"
