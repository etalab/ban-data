# export postgres au format json pour addok

# liste des communes
psql -t -P pager -A -c "
SELECT '{\"id\": \"' || g.insee || (CASE WHEN min_cp!=cp.cp then '_'||cp.cp ELSE '' END)
|| '\",\"type\": \"municipality\",\"name\": \"' || g.nom
|| '\",\"postcode\": \"' || cp.cp
|| '\",\"citycode\": \"' || g.insee
|| '\",\"lon\": ' || round(case when g.insee like '97%' or x_chf_lieu is null then ST_X(ST_Transform(ST_PointOnSurface(wkb_geometry),4326))::numeric else st_x(st_transform(st_setsrid(ST_Point(x_chf_lieu*100,y_chf_lieu*100),2154),4326))::numeric END,6)
|| ',\"lat\": ' || round(case when g.insee like '97%' or x_chf_lieu is null then ST_Y(ST_Transform(ST_PointOnSurface(wkb_geometry),4326))::numeric else st_y(st_transform(st_setsrid(ST_Point(x_chf_lieu*100,y_chf_lieu*100),2154),4326))::numeric END,6)
|| ',\"x\": \"' || x_chf_lieu
|| '00\",\"y\": \"' || y_chf_lieu
|| '00\",\"city\": \"' || g.nom
|| '\",\"context\": \"' || case when g.insee LIKE '97%' then left(g.insee,3) else left(g.insee,2) end || ', ' || case when (dr.nom_dep=g.nom or dr.nom_dep=dr.nom_reg) then case when dr.nom_reg=dr.nom_reg2016 then dr.nom_reg2016 else format('%s (%s)', dr.nom_reg2016, dr.nom_reg) end else dr.nom_dep || ', ' || case when upper(unaccent(replace(dr.nom_reg,'-',' ')))=upper(unaccent(replace(dr.nom_reg2016,'-',' '))) then dr.nom_reg2016 else format('%s (%s)', dr.nom_reg2016, dr.nom_reg) end end
|| '\", \"population\": ' || population
|| ', \"adm_weight\": ' || CASE WHEN statut LIKE 'Capital%' THEN 6 WHEN statut = 'Préfecture de régi' THEN 5 WHEN statut='Préfecture' THEN 4 WHEN statut LIKE 'Sous-pr%' THEN 3 WHEN statut='Chef-lieu canton' THEN 2 ELSE 1 END
|| ', \"importance\": ' || greatest(0.075,round(log((CASE WHEN statut LIKE 'Capital%' THEN 6 WHEN statut = 'Préfecture de régi' THEN 5 WHEN statut='Préfecture' THEN 4 WHEN statut LIKE 'Sous-pr%' THEN 3 WHEN statut='Chef-lieu canton' THEN 2 ELSE 1 END)+log(population+1)/3),4))
|| '}'
FROM osm_communes g
join poste_cp cp on (cp.insee=g.insee)
join (select insee, min(cp) as min_cp from poste_cp group by 1) as cp2 on (cp2.insee=g.insee)
join cog_dep d on (d.dep=left(g.insee,2) or d.dep=left(g.insee,3))
join cog_reg r on (r.reg=d.reg)
join dep_reg_2016 dr on (dr.dep=d.dep)
WHERE g.insee like '$1%'
GROUP BY 1,g.insee, cp.cp
ORDER BY g.insee, cp.cp;
" | grep id

# adresses regroupées par voie/lieu-dit/CP
psql --no-align --tuples-only -P pager -qc "
select format('{\"id\":\"%s_%s\",\"type\":\"%s\",\"name\":\"%s\" %s,\"postcode\":\"%s\",\"citycode\":\"%s\",\"lon\":%s,\"lat\": %s,\"x\":%s,\"y\":%s,\"city\":\"%s\",\"context\":\"%s\",\"importance\":%s,\"housenumbers\":{%s}}',
  code_insee,
  fantoir,
  type,
  case when nom_voie='' then nom_commune when ancienne_commune='' then nom_voie else replace(nom_voie,' '||ancienne_commune,'') || ' ' || ancienne_commune end,
  case when alias !='' then format(',\"alias\":\"%s\"', alias) else '' end,
  code_post,
  code_insee,
  lat,
  lon,
  x,
  y,
  nom_commune,
  case when code_insee LIKE '97%' then left(code_insee,3) else left(code_insee,2) end || ', ' || case when (nom_dep=nom_commune or nom_dep=nom_reg) then nom_reg else nom_dep || ', ' || nom_reg end,
  importance,
  housenumbers)
from
(select code_insee,
(case when id_ld is not null AND coalesce(id_voie,'')!=coalesce(id_ld,'') then coalesce(id_voie,'')||id_ld
when coalesce(id_voie,'')!='' and nom_ld='' then coalesce(id_voie,'')
when id_ld is not null then id_ld
when coalesce(id_voie,'')!='' and nom_ld!='' then coalesce(id_voie,'')
else
'XXXX' end) || '_' || left(md5(format('n=%s,l=%s,a=%s,p=%s',unaccent(nom_voie),nom_ld,alias,code_post)),6) as fantoir,
replace(case when (coalesce(max(nom_voie),'') !='' and coalesce(max(nom_ld),'') !='' and replace(upper(unaccent(coalesce(max(nom_voie),''))),'-',' ')!=replace(upper(unaccent(coalesce(max(nom_ld),''))),'-',' ')) then (coalesce(max(nom_voie),'')||', '||coalesce(max(nom_ld),'')) when (coalesce(max(nom_voie),'')='') then max(nom_ld) else max(nom_voie) end,'\"','') as  nom_voie,
code_post,
round(avg(lat::numeric),6) as lat,
round(avg(lon::numeric),6) as lon,
round(avg(x::numeric),6) as x,
round(avg(y::numeric),6) as y,
regexp_replace(max(nom_commune),' [0-9].*','') as nom_commune,
max(dr.nom_dep) as nom_dep,
max(case when upper(unaccent(replace(dr.nom_reg,'-',' ')))=upper(unaccent(replace(dr.nom_reg2016,'-',' '))) then dr.nom_reg2016 else format('%s (%s)', dr.nom_reg2016, dr.nom_reg) end) as nom_reg,
max(case when coalesce(id_voie,id_ld,id_fantoir) > '9999' then 'locality' else 'street' end) as type,
round(log((CASE WHEN (code_post LIKE '75%' OR max(g.statut) LIKE 'Capital%') THEN 6 WHEN (code_post LIKE '690%' OR code_post LIKE '130%' OR max(g.statut) = 'Préfecture de régi') THEN 5 WHEN max(g.statut)='Préfecture' THEN 4 WHEN max(g.statut) LIKE 'Sous-pr%' THEN 3 WHEN max(g.statut)='Chef-lieu canton' THEN 2 ELSE 1 END)+log(max(g.population)+1)/3)::numeric*log(1+log(count(b.*)+1)+log(CASE WHEN max(nom_voie) like 'Boulevard%' THEN 4 WHEN max(nom_voie) LIKE 'Place%' THEN 4 WHEN max(nom_voie) LIKE 'Espl%' THEN 4 WHEN max(nom_voie) LIKE 'Av%' THEN 3 WHEN max(nom_voie) LIKE 'Rue %' THEN 2 ELSE 1 END))::numeric,4)::text as importance,
string_agg(format('\"%s\":{\"lat\":%s,\"lon\":%s,\"id\":\"%s\",\"x\":%s,\"y\":%s}',trim(numero||' '||rep),round(lon::numeric,6)::text,round(lat::numeric,6)::text,id,x,y),',' order by numero||rep,id) as housenumbers,
max(case when nom_fusion is not null then format('(%s)',nom_fusion) else '' end) as ancienne_commune, alias
from ban_$1 b
join osm_communes g on (g.insee=code_insee)
join cog_dep d on (d.dep=left(code_insee,2) or d.dep=left(code_insee,3))
join cog_reg r on (r.reg=d.reg)
join dep_reg_2016 dr on (dr.dep=d.dep)
where nom_voie||nom_ld!=''
group by 1,2,4,alias
order by 1,2,3) as d;
"
