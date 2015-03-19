# export postgres vers json pour addok des adresses
psql --no-align --tuples-only -c "
select format('{\"id\":\"%s%s\",\"type\":\"%s\",\"name\":\"%s\",\"postcode\":\"%s\",\"lat\":\"%s\",\"lon\": \"%s\",\"city\": \"%s\",\"departement\": \"%s\",\"region\": \"%s\",\"importance\": \"%s\",\"housenumbers\":{%s}',code_insee, id_fantoir, type, replace(nom_voie,'*NOBDUNI*',''), code_post, lat, lon, nom_commune, nom_dept, nom_region, importance, housenumbers)
from
(select code_insee,
coalesce(id_fantoir,'#'||translate(unaccent(UPPER(nom_voie||nom_ld)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -'||chr(39),'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')) as id_fantoir,
case when (nom_voie !='' and nom_ld !='' and replace(upper(unaccent(nom_voie)),'-',' ')!=replace(upper(unaccent(nom_ld)),'-',' ')) then (nom_voie||', '||nom_ld) when (nom_voie='') then nom_ld else nom_voie end as nom_voie,
code_post,
round(avg(st_x(geom))::numeric,6) as lat,
round(avg(st_y(geom))::numeric,6) as lon,
nom_commune,
nom_dept,
nom_region,
case when id_fantoir > '9999' then 'place' else 'street' end as type,
round(log((CASE WHEN (code_post LIKE '75%' OR g.statut LIKE 'Capital%') THEN 6 WHEN (code_post LIKE '690%' OR code_post LIKE '130%' OR g.statut = 'Préfecture de régi') THEN 5 WHEN g.statut='Préfecture' THEN 4 WHEN g.statut LIKE 'Sous-pr%' THEN 3 WHEN g.statut='Chef-lieu canton' THEN 2 ELSE 1 END)+log(g.population+1)/3)::numeric*log(1+log(count(b.*)+1)+log(CASE WHEN nom_voie like 'Boulevard%' THEN 4 WHEN nom_voie LIKE 'Place%' THEN 4 WHEN nom_voie LIKE 'Espl%' THEN 4 WHEN nom_voie LIKE 'Av%' THEN 3 WHEN nom_voie LIKE 'Rue %' THEN 2 ELSE 1 END))::numeric,4)::text as importance,
string_agg(format('\"%s\":{\"lat\":\"%s\",\"lon\":\"%s\"}',trim(numero||' '||rep),round(st_x(geom)::numeric,6)::text,round(st_y(geom)::numeric,6)::text),',' order by numero||rep) as housenumbers
from ban b
join osm_communes g on (g.insee=code_insee)
group by 1,2,3,4,7,8,9,10,g.statut,g.population,nom_voie
order by 1,2,3) as d;
"

