# convert_ban2json.sh n°_departement
TEMPDIR=/run/shm
DEP=$1

echo "`date +%H:%M:%S` Import postgres dept $DEP"
psql -qc "
CREATE TABLE IF NOT EXISTS ban_full (id TEXT,nom_voie TEXT, id_fantoir TEXT, numero TEXT,rep TEXT, code_insee TEXT, code_post TEXT,alias TEXT, nom_ld TEXT, libelle_acheminement TEXT, x FLOAT NOT NULL, y FLOAT NOT NULL,lat FLOAT NOT NULL, lon FLOAT NOT NULL,nom_commune TEXT);
DROP TABLE IF EXISTS BAN_$DEP;
CREATE TABLE ban_$DEP () INHERITS (ban_full);
"

unzip -qjn ../data/ign/livraison/$DEP/*odbl*_$DEP.zip -d ../data/ign/
if grep -q ISO ../data/ign/*odbl*_"$DEP".csv
then
	# conversion UTF8 si ISO en entrée
	iconv -f ISO8859-1 -t UTF8 ../data/ign/*odbl*_$DEP.csv > temp_$DEP
	rm -f ../data/ign/*odbl*_$DEP.csv
	mv temp_$DEP ../data/ign/BAN_odbl_$DEP.csv
fi

grep "^ADR" ../data/ign/*odbl*_$DEP.csv | sort -u > $TEMPDIR/temp_$DEP
psql -c "\copy ban_$DEP from '$TEMPDIR/temp_$DEP' with (format csv, delimiter ';', header false);"
# pas de libellé d'acheminement dans la version ODbL
psql -c "UPDATE ban_$DEP SET libelle_acheminement='';"
rm $TEMPDIR/temp_$DEP

echo "`date +%H:%M:%S` Conformation et indexation dept $DEP"
psql -qc "
-- mise à jour des noms de voie, lieu-dit ou alias nuls
update ban_$DEP set nom_voie='' where nom_voie is null;
update ban_$DEP set nom_ld='' where nom_ld is null;
update ban_$DEP set alias='' where alias is null;
update ban_$DEP set id_fantoir='' where id_fantoir is null;

-- création des index
create index ban_$DEP_id on ban_$DEP using spgist(id);
create index ban_$DEP_insee on ban_$DEP using spgist(code_insee);
"

echo "`date +%H:%M:%S` Harmonisation dept $DEP"
sed "s/ban_temp/ban_$DEP/g;s/!dep!/$DEP/g" clean.sql > $TEMPDIR/clean_$DEP.sql
psql -q < $TEMPDIR/clean_$DEP.sql
rm $TEMPDIR/clean_$DEP.sql

echo "`date +%H:%M:%S` Export JSON dept $DEP"
sh out_pg2json.sh $DEP > ../out/ban-odbl-$DEP.json
echo "`date +%H:%M:%S` Terminé dept $DEP"

