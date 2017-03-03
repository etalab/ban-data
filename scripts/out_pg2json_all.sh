#!/bin/bash
DEPTS=$(echo `seq -w 1 19` 2A 2B `seq 21 95` `seq 971 976`)

echo "`date +%H:%M:%S` Export JSON par département"

# sortie des JSON par département
parallel -j 6 sh out_pg2json.sh {} \> ../out/ban-odbl-{}.json ::: $DEPTS

echo "`date +%H:%M:%S` Concaténation JSON global"

truncate -s 0 ../out/ban-odbl.json
for d in `seq -w 1 19` 2A 2B `seq 21 95` `seq 971 976`
do
  cat ../out/ban-odbl-$d.json >> ../out/ban-odbl.json
done

echo "`date +%H:%M:%S` Fin de traitement"
