# export postgres au format json pour addok

# liste des communes
psql -t -P pager -A -c "
SELECT '{\"id\": \"' || g.insee || (CASE WHEN min_cp!=cp.cp then '_'||cp.cp ELSE '' END)
|| '\",\"type\": \"municipality\",\"name\": \"' || g.nom
|| '\",\"postcode\": \"' || cp.cp
|| '\",\"citycode\": [\"' || g.insee
|| '\"],\"lon\": ' || round(case when g.insee like '97%' or x_chf_lieu is null then ST_X(ST_Transform(ST_PointOnSurface(g.wkb_geometry),4326))::numeric else st_x(st_transform(st_setsrid(ST_Point(x_chf_lieu*100,y_chf_lieu*100),2154),4326))::numeric END,6)
|| ',\"lat\": ' || round(case when g.insee like '97%' or x_chf_lieu is null then ST_Y(ST_Transform(ST_PointOnSurface(g.wkb_geometry),4326))::numeric else st_y(st_transform(st_setsrid(ST_Point(x_chf_lieu*100,y_chf_lieu*100),2154),4326))::numeric END,6)
|| coalesce(',\"x\":' || x_chf_lieu||'00,\"y\":' || y_chf_lieu|| '00'|| ',\"population\": ' || population,'')
|| ',\"city\": ' || to_json(g.nom)
|| ',\"context\": ' || to_json(cc.contexte)
|| ',\"adm_weight\": ' || CASE WHEN statut LIKE 'Capital%' THEN 6 WHEN statut = 'Préfecture de régi' THEN 5 WHEN statut='Préfecture' THEN 4 WHEN statut LIKE 'Sous-pr%' THEN 3 WHEN statut='Chef-lieu canton' THEN 2 ELSE 1 END
|| ', \"importance\": ' || greatest(0.075,round(log((CASE WHEN statut LIKE 'Capital%' THEN 6 WHEN statut = 'Préfecture de régi' THEN 5 WHEN statut='Préfecture' THEN 4 WHEN statut LIKE 'Sous-pr%' THEN 3 WHEN statut='Chef-lieu canton' THEN 2 ELSE 1 END)+log(population+1)/3),4))
|| '}'
FROM osm_communes_2017 g left join osm_communes o on (o.insee=g.insee)
join poste_cp cp on (cp.insee=g.insee)
join (select insee, min(cp) as min_cp from poste_cp group by 1) as cp2 on (cp2.insee=g.insee)
join cog_context cc on (cc.dep = case when g.insee > '97' then left(g.insee,3) else left(g.insee,2) end)
WHERE g.insee like '$1%'
GROUP BY 1,g.insee, cp.cp
ORDER BY g.insee, cp.cp;
" | grep id

# adresses regroupées par voie/lieu-dit/CP
psql --no-align --tuples-only -P pager -qc "
select format('{\"id\":\"%s\",\"type\":\"%s\",\"name\":%s %s,\"postcode\":\"%s\",\"citycode\": %s,\"lon\":%s,\"lat\": %s,\"x\":%s,\"y\":%s,\"city\":\"%s\",\"context\":\"%s\",\"importance\":%s,\"housenumbers\":{%s}}',
  fantoir,
  type,
  format('[%s%s]',to_json(case when nom_voie='' then nom_commune when ancienne_commune='' then nom_voie else replace(nom_voie,' '||ancienne_commune,'') || ' ' || ancienne_commune end)::text, case when alias != '' then ','||to_json(alias) else '' end),
  case when alias !='' then format(',\"alias\":%s', to_json(alias)::text) else '' end,
  code_post,
  format('[%s]', to_json(code_insee)::text || case when insee_2016 is not null and insee_2016!=code_insee then ','||to_json(insee_2016)::text else '' end || case when insee_2015 is not null and insee_2015 != insee_2016 then ','||to_json(insee_2015)::text else '' end || case when code_post like '75%' then ',"75056"' else '' end || case when code_post like '690%' then ',"69123"' else '' end || case when code_post like '130%' then ',"13055"' else '' end),
  lat,
  lon,
  x,
  y,
  nom_commune,
  contexte,
  importance,
  housenumbers)
from
(select code_insee,

(case when id_ld is not null AND id_voie is not null AND id_voie!=id_ld then left(id_voie,10)||substr(id_ld,7,4)
when id_voie is not null and id_ld is null then left(id_voie,10)
when id_voie is null and id_ld is not null then left(id_ld,10)
else code_insee||'_XXXX' end)
 || '_' || left(md5(format('n=%s,l=%s,a=%s,p=%s',unaccent(nom_voie),nom_ld,alias,code_post)),6) as fantoir,

replace(case when (coalesce(max(nom_voie),'') !='' and coalesce(max(nom_ld),'') !='' and replace(upper(unaccent(coalesce(max(nom_voie),''))),'-',' ')!=replace(upper(unaccent(coalesce(max(nom_ld),''))),'-',' ')) then (coalesce(max(nom_voie),'')||', '||coalesce(max(nom_ld),'')) when (coalesce(max(nom_voie),'')='') then max(nom_ld) else max(nom_voie) end,'\"','') as  nom_voie,
code_post,
round(st_y(st_closestpoint(st_collect(st_makepoint(lon,lat)), st_centroid(st_collect(st_makepoint(lon,lat)))))::numeric,6) as lat,
round(st_x(st_closestpoint(st_collect(st_makepoint(lon,lat)), st_centroid(st_collect(st_makepoint(lon,lat)))))::numeric,6) as lon,
round(st_x(st_closestpoint(st_collect(st_makepoint(x,y)), st_centroid(st_collect(st_makepoint(x,y)))))::numeric,1) as x,
round(st_y(st_closestpoint(st_collect(st_makepoint(x,y)), st_centroid(st_collect(st_makepoint(x,y)))))::numeric,1) as y,
regexp_replace(max(nom_commune),' [0-9].*','') as nom_commune,
max(cc.contexte) as contexte,
max(case when coalesce(id_voie,id_ld,id_fantoir) > '9999' then 'locality' else 'street' end) as type,
round(log((CASE WHEN (code_post LIKE '75%' OR max(g.statut) LIKE 'Capital%') THEN 6 WHEN (code_post LIKE '690%' OR code_post LIKE '130%' OR max(g.statut) = 'Préfecture de régi') THEN 5 WHEN max(g.statut)='Préfecture' THEN 4 WHEN max(g.statut) LIKE 'Sous-pr%' THEN 3 WHEN max(g.statut)='Chef-lieu canton' THEN 2 ELSE 1 END)+log(max(coalesce(g.population,0))+1)/3)::numeric*log(1+log(count(b.*)+1)+log(CASE WHEN max(nom_voie) like 'Boulevard%' THEN 4 WHEN max(nom_voie) LIKE 'Place%' THEN 4 WHEN max(nom_voie) LIKE 'Espl%' THEN 4 WHEN max(nom_voie) LIKE 'Av%' THEN 3 WHEN max(nom_voie) LIKE 'Rue %' THEN 2 ELSE 1 END))::numeric,4)::text as importance,
string_agg(format('\"%s\":{\"lat\":%s,\"lon\":%s,\"id\":\"%s\",\"x\":%s,\"y\":%s}',trim(coalesce(numero,'')||' '||coalesce(rep,'')),round(lon::numeric,6)::text,round(lat::numeric,6)::text,id,x,y),',' order by numero||rep,id) as housenumbers,
max(case when nom_fusion is not null then format('(%s)',nom_fusion) else '' end) as ancienne_commune, alias, insee_2016, insee_2015
from ban_$1 b
join osm_communes g on (g.insee=code_insee)
join cog_context cc on (cc.dep = case when code_insee LIKE '97%' then left(code_insee,3) else left(code_insee,2) end)
where nom_voie||nom_ld!=''
group by 1,2,4,alias, insee_2016, insee_2015
order by 1,2,3) as d;
"
