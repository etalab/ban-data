# contrôle de cohérence et détection d'erreurs et anomalies sur la colonne code_post (code postal)

# chaine de connexion à la base postgres locale
DB=postgresql:///cquest

echo "\n-- code_post est vide (groupé par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb from ban_temp where code_post='' group by 1 order by 1;"
sql2csv --db "$DB" -H --query "select code_insee,id,'code_post','','code_post est vide' from ban_temp where code_post='' or code_post is null" >> erreurs.csv

echo "\n-- code_post inconnu\n"
sql2csv --db "$DB" -H --query "select code_insee,id,'code_post',code_post,'code_post inconnu' from ban_temp b left join poste_cp p on (p.cp=b.code_post) where p.cp is null and b.code_post !=''" >> erreurs.csv

