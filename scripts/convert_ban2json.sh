echo "Import postgres $1"
psql -qc "
drop table if exists ban_temp; 
CREATE TABLE ban_temp (
	id TEXT,
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
	lat FLOAT NOT NULL, 
	lon FLOAT NOT NULL, 
	nom_commune TEXT
);"

psql -c "\copy ban_temp from $1 with (format csv, delimiter ';', header true);"

echo "Conformation et indexation"
psql -qc "
-- mise à jour des noms de voie, lieu-dit ou alias nuls
update ban_temp set nom_voie='' where nom_voie is null;
update ban_temp set nom_ld='' where nom_ld is null;
update ban_temp set alias='' where alias is null;
update ban_temp set id_fantoir='' where id_fantoir is null;

-- création des index
create index ban_temp_id on ban_temp using spgist(id);
create index ban_temp_insee on ban_temp using spgist(code_insee);
"

echo "Harmonisation"
psql -q < clean.sql

echo "Export JSON vers $2"
# export postgres vers json pour addok des adresses
psql --no-align --tuples-only -qc "
select format('{\"id\":\"%s_%s\",\"type\":\"%s\",\"name\":\"%s\",\"postcode\":\"%s\",\"lon\":%s,\"lat\": %s,\"city\":\"%s\",\"departement\":\"%s\",\"region\":\"%s\",\"importance\":%s,\"housenumbers\":{%s}}',code_insee, id_fantoir, type, nom_voie, code_post, lat, lon, nom_commune, nom_dep, nom_reg, importance, housenumbers)
from
(select code_insee, (case when id_fantoir='' then 'XXXX' else id_fantoir end) || '_' ||
left(md5(format('f=%s,n=%s,l=%s,a=%s,p=%s',id_fantoir,nom_voie,nom_ld,alias,code_post)),8) id_fantoir,
case when (coalesce(nom_voie,'') !='' and coalesce(nom_ld,'') !='' and replace(upper(unaccent(coalesce(nom_voie,''))),'-',' ')!=replace(upper(unaccent(coalesce(nom_ld,''))),'-',' ')) then (coalesce(nom_voie,'')||', '||coalesce(nom_ld,'')) when (coalesce(nom_voie,'')='') then nom_ld else nom_voie end as nom_voie,
code_post,
round(avg(lat::numeric),6) as lat,
round(avg(lon::numeric),6) as lon,
nom_commune,
nom_dep,
nom_reg,
case when id_fantoir > '9999' then 'place' else 'street' end as type,
round(log((CASE WHEN (code_post LIKE '75%' OR g.statut LIKE 'Capital%') THEN 6 WHEN (code_post LIKE '690%' OR code_post LIKE '130%' OR g.statut = 'Préfecture de régi') THEN 5 WHEN g.statut='Préfecture' THEN 4 WHEN g.statut LIKE 'Sous-pr%' THEN 3 WHEN g.statut='Chef-lieu canton' THEN 2 ELSE 1 END)+log(g.population+1)/3)::numeric*log(1+log(count(b.*)+1)+log(CASE WHEN nom_voie like 'Boulevard%' THEN 4 WHEN nom_voie LIKE 'Place%' THEN 4 WHEN nom_voie LIKE 'Espl%' THEN 4 WHEN nom_voie LIKE 'Av%' THEN 3 WHEN nom_voie LIKE 'Rue %' THEN 2 ELSE 1 END))::numeric,4)::text as importance,
string_agg(format('\"%s\":{\"lat\":%s,\"lon\":%s,\"id\":\"%s\"}',trim(numero||' '||rep),round(lon::numeric,6)::text,round(lat::numeric,6)::text,id),',' order by numero||rep) as housenumbers
from ban_temp b
join osm_communes g on (g.insee=code_insee)
join cog_dep d on (d.dep=left(code_insee,2) or d.dep=left(code_insee,3))
join cog_reg r on (r.reg=d.reg)
group by 1,2,3,4,7,8,9,10,g.statut,g.population,nom_voie
order by 1,2,3) as d;
" >> $2


