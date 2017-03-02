# convert_ban2json.sh n°_departement
TEMPDIR=/run/shm
DEP=$1

echo "`date +%H:%M:%S` Import postgres dept $DEP"
psql -qc "
CREATE TABLE IF NOT EXISTS ban_full (id TEXT,nom_voie TEXT, id_fantoir TEXT, numero TEXT,rep TEXT, code_insee TEXT, code_post TEXT,alias TEXT, nom_ld TEXT, libelle_acheminement TEXT, x FLOAT NOT NULL, y FLOAT NOT NULL,lat FLOAT NOT NULL, lon FLOAT NOT NULL,nom_commune TEXT);
DROP TABLE IF EXISTS BAN_$DEP;
CREATE TABLE ban_$DEP () INHERITS (ban_full);
"

# unzip -qjn ../data/ign/livraison/$DEP/*odbl*_$DEP.zip -d ../data/ign/
if file ../data/ign/*odbl*_"$DEP".csv | grep -q ISO
then
	# conversion UTF8 si ISO en entrée
	iconv -f WINDOWS-1252 -t UTF8 ../data/ign/*odbl*_$DEP.csv > temp_$DEP
	rm -f ../data/ign/*odbl*_$DEP.csv
	mv temp_$DEP ../data/ign/BAN_odbl_$DEP.csv
fi

grep "^ADR" ../data/ign/*odbl*_$DEP.csv | sort -u > $TEMPDIR/temp_$DEP
psql -c "\copy ban_$DEP from '$TEMPDIR/temp_$DEP' with (format csv, delimiter ';', header false, NULL '');"
# pas de libellé d'acheminement dans la version ODbL
psql -c "UPDATE ban_$DEP SET libelle_acheminement='';"
rm $TEMPDIR/temp_$DEP


echo "`date +%H:%M:%S` Normalisation voies/ld dept $DEP"

psql -qc "
DROP TABLE IF EXISTS ban_group_$DEP;
CREATE TABLE ban_group_$DEP AS SELECT code_insee, code_post, nom_commune, nom_voie, nom_ld, alias, id_fantoir, null as nom_temp, null as ld_temp, null as id_voie, null as id_ld, to_hex(nextval('ban_id')) as id, array_agg(id) as ids FROM ban_$DEP GROUP BY 1,2,3,4,5,6,7,8,9,10,11;
UPDATE ban_group_$DEP SET nom_voie = '' WHERE nom_voie IS NULL;
UPDATE ban_group_$DEP SET nom_ld = '' WHERE nom_ld IS NULL;
UPDATE ban_group_$DEP SET alias = '' WHERE alias IS NULL;
UPDATE ban_group_$DEP SET id_fantoir = '' WHERE id_fantoir IS NULL;
"

echo "`date +%H:%M:%S` Indexation dept $DEP"
psql -qc "
-- création des index
alter table ban_$DEP add id_voie text;
alter table ban_$DEP add id_ld text;

create index ban_id_$DEP on ban_$DEP using spgist(id);
create index ban_insee_$DEP on ban_$DEP using spgist(code_insee);
create index ban_group_insee_$DEP on ban_group_$DEP using spgist(code_insee);
create index ban_voie_vide_$DEP on ban_$DEP (id) where id_voie is null and nom_voie!='';
create index ban_ld_vide_$DEP on ban_$DEP (id) where id_ld is null and nom_ld !='';
-- index trigrams pour accélérer les regexp / LIKE
create index ban_nom_voie_$DEP on ban_group_$DEP using  gist (nom_voie gist_trgm_ops);
create index ban_nom_ld_$DEP on ban_group_$DEP using  gist (nom_ld gist_trgm_ops);

-- nettoyage nom_ld qui contient un code FANTOIR (issue #99)
with u as (select b.id as u_id, libelle_voie as u_nom from ban_group_$DEP b join dgfip_fantoir f on (b.code_insee=f.code_insee and f.id_voie=nom_ld) where nom_ld ~ '^[0-9A-Z][0-9][0-9][0-9]$')
  update ban_group_$DEP set nom_ld=u_nom from u where id=u_id;

"

# mise à jour des libellés (nom_voie / nom_ld > court)
echo "`date +%H:%M:%S` Mise à jour libellés longs>courts $DEP"
sh abrev_load_dep.sh $DEP > /dev/null
sh abrev_update.sh > /dev/null

echo "`date +%H:%M:%S` Harmonisation dept $DEP"
sed "s/BAN_TEMP/ban_$DEP/g;s/ban_temp/ban_group_$DEP/g;s/\!dep\!/$DEP/g" clean.sql > clean_$DEP.sql

psql -q < clean_$DEP.sql > /dev/null
# rm clean_$DEP.sql

exit

echo "`date +%H:%M:%S` Export JSON dept $DEP"
sh out_pg2json.sh $DEP > ../out/ban-odbl-$DEP.json

echo "`date +%H:%M:%S` Export CSV par commune $DEP"
sh out_csv_communes.sh $DEP

echo "`date +%H:%M:%S` Terminé dept $DEP"
