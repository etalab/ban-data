cd ../data/ign/livraison/
psql -qc "drop table if exists ban_temp; CREATE TABLE ban_temp (
	id TEXT,
	nom_voie TEXT, 
	id_fantoir TEXT, 
	numero TEXT, 
	rep TEXT, 
	code_insee TEXT, 
	code_post TEXT, 
	alias TEXT, 
	nom_ld TEXT,
	nom_afnor TEXT, 
	libelle_acheminement TEXT, 
	x FLOAT NOT NULL, 
	y FLOAT NOT NULL, 
	lon FLOAT NOT NULL, 
	lat FLOAT NOT NULL, 
	nom_commune TEXT
);"
for f in *.csv; do
	echo $f
	if file $f | grep -q ISO
	then
		# conversion UTF8 si ISO en entrée
		iconv -f ISO8859-1 -t UTF8 $f > temp
		echo "conversion ISO > UTF de $f"
		rm -f $f
		mv temp $f
	fi
	tail -n +2 $f | sort -u > temp
	psql -c "\copy ban_temp from temp with (format csv, delimiter ';', header false);"
done

psql -c "
-- mise à jour des noms de voie, lieu-dit ou alias nuls
update ban_temp set nom_voie='' where nom_voie is null;
update ban_temp set nom_ld='' where nom_ld is null;
update ban_temp set nom_afnor='' where nom_afnor is null;
update ban_temp set alias='' where alias is null;
update ban_temp set id_fantoir='' where id_fantoir is null;

-- création des index
create index ban_temp_id on ban_temp using spgist(id);
create index ban_temp_insee on ban_temp using spgist(code_insee);
"

