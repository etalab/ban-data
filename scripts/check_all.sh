CSVDIR=../data/ign/livraison
echo "suppression anciens fichiers CSV"
rm -f $CSVDIR/*.csv
echo "décompressions fichiers CSV"
for f in $CSVDIR/$1/*.zip; do unzip -qjn $f -d $CSVDIR; done
rm -f $CSVDIR/*97*.csv

sh in_ban2pg.sh
rm -f erreurs.csv
sh check_code_insee.sh
sh check_code_post.sh
sh check_fantoir.sh
sh check_id.sh
sh check_nom_commune.sh
sh check_nom_voie.sh
sh check_numero_rep.sh

echo "-- recherche adresses hexacle introuvables"
parallel -j 4 sh check_ran.sh {} ::: 01 02 03 04 05 06 07 08 09 `seq 10 19` 2A 2B `seq 21 95`
for d in 01 02 03 04 05 06 07 08 09 `seq 10 19` 2A 2B `seq 21 95`; do cat check_ran_$d >> erreurs.csv; rm check_ran_$d; done

gzip erreurs.csv -9 --rsyncable -c > anomalies-$1.csv.gz
