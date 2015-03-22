# contrôle de cohérence et détection d'erreurs et anomalies sur la colonne nom_commune

# chaine de connexion à la base postgres locale
DB=postgresql:///cquest

echo "\n-- nom_commune est vide (groupé par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb from ban_temp where nom_commune='' group by 1 order by 1;"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_commune','','nom_commune est vide' from ban_temp where nom_commune='' or nom_commune is null" >> erreurs.csv

echo "\n-- code_post inconnu\n"
sql2csv --db "$DB" -H --query "select code_insee,id,'code_post',code_post,'code_post inconnu' from ban_temp b left join poste_cp p on (p.cp=b.code_post) where p.cp is null and b.code_post !=''" >> erreurs.csv

