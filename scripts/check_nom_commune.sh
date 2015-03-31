# contrôle de cohérence et détection d'erreurs et anomalies sur la colonne nom_commune

# chaine de connexion à la base postgres locale
DB=postgresql:///cquest

echo "\n-- nom_commune est vide (groupé par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb from ban_temp where nom_commune='' group by 1 order by 1;"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_commune','','nom_commune est vide' from ban_temp where nom_commune='' or nom_commune is null" >> erreurs.csv

echo "\n-- nom_commune inconnu\n"
sql2csv --db "$DB" -H --query "select code_insee,id,'code_post',code_post,'code_post inconnu' from ban_temp b left join poste_cp p on (p.cp=b.code_post) where p.cp is null and b.code_post !=''" >> erreurs.csv

echo "\n-- nom_commune ne correspond pas au COG 2014\n"
sql2csv --db "$DB" -H --query "select b.code_insee, b.id, 'nom_commune', b.nom_commune, 'nom_commune ne correspond pas au COG 2014: ' || trim(replace(replace(c.artmin||' '||c.nccenr,'(',''),')','')) from ban_temp b left join insee_cog_2014 c on (c.insee=b.code_insee) where trim(replace(replace(c.artmin||c.nccenr,'(',''),')','')) != replace(b.nom_commune,' ','') and NOT b.nom_commune ~ 'rondissement$'" >> erreurs.csv

echo "\n-- nom_commune = nom_ld"
sql2csv --db "$DB" -H --query "select b.code_insee, b.id, 'nom_commune', b.nom_commune, 'nom_commune identique à nom_ld: ' || nom_ld from ban_temp b where nom_ld !='' and lower(nom_ld)=replace(lower(unaccent(nom_commune)),'-',' ')" >> erreurs.csv

