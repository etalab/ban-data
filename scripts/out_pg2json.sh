# export postgres au format json pour addok
psql --no-align --tuples-only -P pager -qc "
select format('{\"id\":\"%s_%s\",\"type\":\"%s\",\"name\":\"%s\",\"postcode\":\"%s\",\"citycode\":\"%s\",\"lon\":%s,\"lat\": %s,\"city\":\"%s\",\"context\":\"%s\",\"importance\":%s,\"housenumbers\":{%s}}',code_insee, fantoir, type, case when nom_voie='' then nom_commune else nom_voie end, code_post, code_insee, lat, lon, nom_commune, case when code_insee LIKE '97%' then left(code_insee,3) else left(code_insee,2) end || ', ' || case when (nom_dep=nom_commune or nom_dep=nom_reg) then nom_reg else nom_dep || ', ' || nom_reg end , importance, housenumbers)
from
(select code_insee,

(case when id_ld is not null AND coalesce(id_voie,'')!=coalesce(id_ld,'') then coalesce(id_voie,'')||id_ld
when coalesce(id_voie,'')!='' and nom_ld='' then coalesce(id_voie,'')
when id_ld is not null then id_ld
when coalesce(id_voie,'')!='' and nom_ld!='' then coalesce(id_voie,'')
else
'XXXX' end) || '_' || left(md5(format('n=%s,l=%s,a=%s,p=%s',nom_voie,nom_ld,alias,code_post)),6)
 as fantoir,

case when (coalesce(nom_voie,'') !='' and coalesce(nom_ld,'') !='' and replace(upper(unaccent(coalesce(nom_voie,''))),'-',' ')!=replace(upper(unaccent(coalesce(nom_ld,''))),'-',' ')) then (coalesce(nom_voie,'')||', '||coalesce(nom_ld,'')) when (coalesce(nom_voie,'')='') then nom_ld else nom_voie end as nom_voie,
code_post,
round(avg(lat::numeric),6) as lat,
round(avg(lon::numeric),6) as lon,
regexp_replace(nom_commune,' [0-9].*','') as nom_commune,
nom_dep,
nom_reg,
case when coalesce(id_voie,id_ld,id_fantoir) > '9999' then 'locality' else 'street' end as type,
round(log((CASE WHEN (code_post LIKE '75%' OR g.statut LIKE 'Capital%') THEN 6 WHEN (code_post LIKE '690%' OR code_post LIKE '130%' OR g.statut = 'Préfecture de régi') THEN 5 WHEN g.statut='Préfecture' THEN 4 WHEN g.statut LIKE 'Sous-pr%' THEN 3 WHEN g.statut='Chef-lieu canton' THEN 2 ELSE 1 END)+log(g.population+1)/3)::numeric*log(1+log(count(b.*)+1)+log(CASE WHEN nom_voie like 'Boulevard%' THEN 4 WHEN nom_voie LIKE 'Place%' THEN 4 WHEN nom_voie LIKE 'Espl%' THEN 4 WHEN nom_voie LIKE 'Av%' THEN 3 WHEN nom_voie LIKE 'Rue %' THEN 2 ELSE 1 END))::numeric,4)::text as importance,
string_agg(format('\"%s\":{\"lat\":%s,\"lon\":%s,\"id\":\"%s\"}',trim(numero||' '||rep),round(lon::numeric,6)::text,round(lat::numeric,6)::text,id),',' order by numero||rep,id) as housenumbers
from ban_$1 b
join osm_communes g on (g.insee=code_insee)
join cog_dep d on (d.dep=left(code_insee,2) or d.dep=left(code_insee,3))
join cog_reg r on (r.reg=d.reg)
group by 1,2,3,4,7,8,9,10,g.statut,g.population,nom_voie
order by 1,2,3) as d;
"

psql -t -P pager -A -c "
SELECT '{\"id\": \"' || g.insee || '\",\"type\": \"' || CASE WHEN population<1 THEN 'village' WHEN population<'10' THEN 'town' ELSE 'city' END  || '\",\"name\": \"' || g.nom || '\",\"postcode\": \"' || cp.cp || '\",\"citycode\": \"' || g.insee || '\",\"lat\": \"' || round(st_y(st_transform(st_setsrid(ST_Point(x_chf_lieu*100,y_chf_lieu*100),2154),4326))::numeric,6) || '\",\"lon\": \"' || round(st_x(st_transform(st_setsrid(ST_Point(x_chf_lieu*100,y_chf_lieu*100),2154),4326))::numeric,6) || '\",\"city\": \"' || g.nom|| '\",\"context\": \"' || case when g.insee LIKE '97%' then left(g.insee,3) else left(g.insee,2) end || ', ' || case when (nom_dep=g.nom or nom_dep=nom_reg) then nom_reg else nom_dep || ', ' || nom_reg end || '\", \"population\": ' || population || ', \"adm_weight\": ' || CASE WHEN statut LIKE 'Capital%' THEN 6 WHEN statut = 'Préfecture de régi' THEN 5 WHEN statut='Préfecture' THEN 4 WHEN statut LIKE 'Sous-pr%' THEN 3 WHEN statut='Chef-lieu canton' THEN 2 ELSE 1 END || ', \"importance\": ' || greatest(0.075,round(log((CASE WHEN statut LIKE 'Capital%' THEN 6 WHEN statut = 'Préfecture de régi' THEN 5 WHEN statut='Préfecture' THEN 4 WHEN statut LIKE 'Sous-pr%' THEN 3 WHEN statut='Chef-lieu canton' THEN 2 ELSE 1 END)+log(population+1)/3),4)) || '}'
FROM osm_communes g
join poste_cp cp on (cp.insee=g.insee)
join cog_dep d on (d.dep=left(g.insee,2) or d.dep=left(g.insee,3))
join cog_reg r on (r.reg=d.reg)
WHERE g.insee like '$1%' order by g.insee;
" | grep id

