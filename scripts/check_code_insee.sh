# contrôle de cohérence et détection d'erreurs et anomalies sur la colonne code_insee

# chaine de connexion à la base postgres locale
DB=postgresql:///cquest

echo "\n-- code_insee est vide (groupé par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb from ban_temp where code_insee='' or code_insee is null group by 1 order by 1;"
sql2csv --db "$DB" -H --query "select code_insee,id,'code_insee','','code_insee est vide' from ban_temp where code_insee='' or code_insee is null" >> erreurs.csv

echo "\n-- code_insee inconnu\n"
sql2csv --db "$DB" -H --query "select b.code_insee, b.id, 'code_insee',b.code_insee,'code_insee inconnu' from ban_temp b left join insee_cog_2015 c on (c.insee=b.code_insee) where c.insee is null and NOT b.nom_commune ~ 'rondissement$' group by 1,2" >> erreurs.csv

