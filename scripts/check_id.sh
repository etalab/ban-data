# chaine de connexion à la base postgres locale
DB=postgresql:///cquest

echo "\n-- nombre d'ID vides, nuls ou ne commençant pas par ADR\n"
psql -c "select left(code_insee,2) as dept, count(*) as nb from ban_temp where id is null or id='' or id not like 'ADR%' group by 1;" -P pager
sql2csv --db "$DB" -H --query "select id,'id','','id pas de la forme ADRNIXV_nnnnnn' from ban_temp where NOT id ~ '^ADRNIVX_[0-9]*' " >> erreurs.csv

echo "\n-- comparaison nombre total d'adresses et ID distincts par département\n"
psql -c "select left(code_insee,2) as dept, count(*) as total, count(distinct(id)) as id_distincts, count(*)-count(distinct(id)) as doublons from ban_temp group by 1 order by 1;" -P pager

echo "\n-- nombre de doublons par département\n"
psql -c "select left(code_insee,2) as dept, sum(nb) as nb_id_doublons from (select id, code_insee, count(*) as nb from ban_temp group by 1,2) as ids where nb>1 group by 1 order by 1;" -P pager

sql2csv --db "$DB" -H --query "select code_insee,id,'id',id,'id en double' from (select code_insee, id, count(*) as nb from ban_temp group by 1,2) as ids where nb>1 " >> erreurs.csv

