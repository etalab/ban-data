# convert_ban2json.sh n°_departement
TEMPDIR=/run/shm

echo "`date +%H:%M:%S` Import postgres dept $1"
psql -qc "
CREATE TABLE IF NOT EXISTS ban_full (id TEXT,nom_voie TEXT, id_fantoir TEXT, numero TEXT,rep TEXT, code_insee TEXT, code_post TEXT,alias TEXT, nom_ld TEXT, libelle_acheminement TEXT, x FLOAT NOT NULL, y FLOAT NOT NULL,lat FLOAT NOT NULL, lon FLOAT NOT NULL,nom_commune TEXT);
DROP TABLE IF EXISTS BAN_$1;
CREATE TABLE ban_$1 () INHERITS (ban_full);
"

unzip -qjn ../data/ign/livraison/$1/*odbl*_$1.zip -d ../data/ign/
if grep -q ISO ../data/ign/*odbl*_"$1".csv
then
	# conversion UTF8 si ISO en entrée
	iconv -f ISO8859-1 -t UTF8 ../data/ign/*odbl*_$1.csv > temp_$1
	rm -f ../data/ign/*odbl*_$1.csv
	mv temp_$1 ../data/ign/*odbl*_$1.csv
fi

tail -n +2 ../data/ign/*odbl*_$1.csv | sort -u > $TEMPDIR/temp_$1
psql -c "\copy ban_$1 from '$TEMPDIR/temp_$1' with (format csv, delimiter ';', header false);"
# pas de libellé d'acheminement dans la version ODbL
psql -c "UPDATE ban_$1 SET libelle_acheminement='';"
rm $TEMPDIR/temp_$1

echo "`date +%H:%M:%S` Conformation et indexation dept $1"
psql -qc "
-- mise à jour des noms de voie, lieu-dit ou alias nuls
update ban_$1 set nom_voie='' where nom_voie is null;
update ban_$1 set nom_ld='' where nom_ld is null;
update ban_$1 set alias='' where alias is null;
update ban_$1 set id_fantoir='' where id_fantoir is null;

-- création des index
create index ban_$1_id on ban_$1 using spgist(id);
create index ban_$1_insee on ban_$1 using spgist(code_insee);
"

echo "`date +%H:%M:%S` Harmonisation dept $1"
sed "s/ban_temp/ban_$1/g" clean.sql > $TEMPDIR/clean_$1.sql
psql -q < $TEMPDIR/clean_$1.sql
rm $TEMPDIR/clean_$1.sql

echo "`date +%H:%M:%S` Export JSON dept $1"
sh out_pg2json.sh $1 > ../out/ban-odbl-$1.json
echo "`date +%H:%M:%S` Terminé dept $1"

