#!/bin/bash

# liste des départements à traiter
DEPTS=$(echo `seq -w 1 19` 2A 2B `seq 21 95` `seq 971 976`)

# make sure we run this script with bash
if [ ! "$BASH_VERSION" ] ; then
    exec /bin/bash "$0" "$@"
fi

echo "`date +%H:%M:%S` début de traitement"

# conversion/conformation/harmonisation en multi-thread des fichiers BAN en json pour addok
parallel -j 6 sh convert_ban2json.sh {} ::: $DEPTS

# export des fichiers CSV, SHP
parallel -j 6 sh out_odbl.sh {} ::: $DEPTS

echo "`date +%H:%M:%S` Fusion des fichiers json"
# fusion en un fichier unique
truncate -s 0 ../out/ban-odbl.json
for dep in $DEPTS ; do
  grep -v '^$' "../out/ban-odbl-$dep.json" >> ../out/ban-odbl.json
done

echo "`date +%H:%M:%S` Compression du fichier fusionné"
cat ../out/ban-odbl.json | bzip2 -9 > ../out/odbl/BAN_odbl.json.bz2

echo "`date +%H:%M:%S` fin de traitement"
