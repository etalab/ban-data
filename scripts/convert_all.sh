#!/bin/bash

# make sure we run this script with bash
if [ ! "$BASH_VERSION" ] ; then
    exec /bin/bash "$0" "$@"
fi

echo "`date +%H:%M:%S` début de traitement"

# conversion/conformation/harmonisation en multi-thread des fichiers BAN en json pour addok
parallel -j 8 sh convert_ban2json.sh {} ::: 01 02 03 04 05 06 07 08 09 `seq 10 19` 2A 2B `seq 21 95` `seq 971 976`

echo "`date +%H:%M:%S` Fusion des fichiers json"
# fusion en un fichier unique
truncate -s 0 ../out/ban-odbl.json
for dep in {01..19} 2A 2B {21..95} {971..976} ; do
	sh out_odbl.sh $dep
	grep -v '^$' "../out/ban-odbl-$dep.json" >> ../out/ban-odbl.json
done

echo "`date +%H:%M:%S` Compression du fichier fusionné"
cat ../out/ban-odbl.json | bzip2 -9 > ../out/odbl/BAN_odbl.json.bz2

echo "`date +%H:%M:%S` fin de traitement"
