# contrôle de cohérence et détection d'erreurs et anomalies sur la colonne nom_commune

. $(dirname $0)/config.sh

echo "-- nom_commune est vide (groupé par département)"
#psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb from ban_temp where nom_commune='' group by 1 order by 1;"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_commune','','nom_commune est vide' from ban_temp where nom_commune='' or nom_commune is null" >> erreurs.csv

echo "-- nom_commune inconnu"
sql2csv --db "$DB" -H --query "select code_insee,id,'code_post',code_post,'code_post inconnu' from ban_temp b left join poste_cp p on (p.cp=b.code_post) where p.cp is null and b.code_post !=''" >> erreurs.csv

echo "-- nom_commune ne correspond pas au COG 2015"
sql2csv --db "$DB" -H --query "select b.code_insee, b.id, 'nom_commune', b.nom_commune, 'nom_commune ne correspond pas au COG 2015: ' || trim(replace(replace(c.artmin||' '||c.nccenr,'(',''),')','')) from ban_temp b left join insee_cog_2015 c on (c.insee=b.code_insee) where trim(replace(replace(c.artmin||c.nccenr,'(',''),')','')) != replace(b.nom_commune,' ','') and NOT b.nom_commune ~ 'rondissement$'" >> erreurs.csv

echo "-- nom_commune = nom_ld"
sql2csv --db "$DB" -H --query "select b.code_insee, b.id, 'nom_commune', b.nom_commune, 'nom_commune et nom_ld identiques: ' || nom_ld from ban_temp b where nom_ld !='' and replace(replace(unaccent(lower(nom_commune)),'-',' '),chr(39),' ')=replace(replace(lower(nom_ld),'-',' '),chr(39),' ')" >> erreurs.csv

