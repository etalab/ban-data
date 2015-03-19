cd ../data/ign
psql -c "CREATE TABLE IF NOT EXISTS ban_temp (
	nom_voie TEXT, 
	id_fantoir TEXT, 
	numero TEXT, 
	rep TEXT, 
	code_insee TEXT, 
	code_post TEXT, 
	alias TEXT, 
	nom_ld TEXT, 
	x FLOAT NOT NULL, 
	y FLOAT NOT NULL, 
	lon FLOAT NOT NULL, 
	lat FLOAT NOT NULL, 
	nom_commune TEXT
); TRUNCATE ban_temp;"
for f in ign/*.csv; do
	psql -c "\copy ban_temp from $f with (format csv, delimiter ';', header true);"
done

psql -c "
-- import initial de la table ban
drop table if exists ban;
create table ban as (select b.code_insee || '_' || coalesce(id_fantoir||cle_rivoli,'#'||translate(unaccent(UPPER(nom_voie||nom_ld)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -'||chr(39),'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')) || '_' || coalesce(numero,'') || '_' || coalesce(rep,'') as cle, b.code_insee, id_fantoir||coalesce(cle_rivoli,'') as id_fantoir, numero, rep, replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(initcap(nom_voie),' Du ',' du '),' De ',' de '),' Le ',' le '),' La ',' la '),' Des ',' des '),' L'||chr(39),' l'||chr(39)),' D'||chr(39),' d'||chr(39)),' Au ',' au '),' Aux ',' aux '),' À ',' à '),' Et ',' et '),' Dit ',' dit '),' Dite ',' dite '),' En ',' en ') as nom_voie, nom_ld, alias, code_post, nom_commune, st_makepoint(avg(lon),avg(lat)) as geom from ban_temp b left join dgfip_fantoir f on (f.code_insee=b.code_insee and f.id_voie=b.id_fantoir) group by 1,2,3,4,5,6,7,8,9,10);
-- mise à jour des noms de voie multiples (séparés par '/') si alias vide
update ban set nom_voie=left(nom_voie,position('/' in nom_voie)-1), alias=substring(nom_voie,position('/' in nom_voie)+1) where nom_voie like '%/%' and alias='';
create index ban_cle on ban using spgist(cle);

drop table ban_temp;
"

