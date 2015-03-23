# chaine de connexion à la base postgres locale
DB=postgresql:///cquest

echo "\n-- numéros non numériques\n"
sql2csv --db "$DB" -H --query "select code_insee,id,'numero',numero,'numero non numerique' from ban_temp where NOT numero ~ '[0-9]*'" >> erreurs.csv

echo "\n-- numéros commençant par 0\n"
sql2csv --db "$DB" -H --query "select code_insee,id,'numero',numero,'numero commence par 0' from ban_temp where numero ~ '^0'" >> erreurs.csv

echo "\n-- pseudo-numéros (supérieurs en 5xxx ou 9xxx) et numéros à 0 (groupés par département)\n"
psql -P pager -c "select *, round(100*sup5000/total,1) as pct_5000, round(100*sup9000/total,1) as pct_9000, round(100*numero0/total,1) as pct_0 from (select left(code_insee,2) as dept, count(*) as total, sum(case when numero::numeric>4999 then 1 else 0 end) as sup5000, sum(case when numero::numeric>8999 then 1 else 0 end) as sup9000, sum(case when numero='0' then 1 else 0 end) as numero0 from ban_temp group by 1) as n order by dept;"
sql2csv --db "$DB" -H --query "select code_insee,id,'numero',numero,'numero en 5xxx' from ban_temp where numero::numeric>=5000 and numero::numeric<8999" >> erreurs.csv
sql2csv --db "$DB" -H --query "select code_insee,id,'numero',numero,'numero en 9xxx' from ban_temp where numero::numeric>=9000" >> erreurs.csv

echo "\n-- indice de répétition en minuscule\n"
sql2csv --db "$DB" -H --query "select code_insee,id,'rep',rep,'rep en minuscule' from ban_temp where rep != upper(rep)" >> erreurs.csv

echo "\n-- adresses en doublon\n"
psql -c "\copy (select code_insee, unnest(doublons), 'numero+rep',numero,format('numero+rep en %s doublons: %s',nb::text,adr) from (select code_insee, array_agg(distinct(id)) as doublons, numero, trim(numero||' '||rep)||' '||nom_voie||' '||nom_ld as adr, count(*) as nb from ban_temp group by code_insee,nom_voie,nom_ld,numero,rep) as d where nb>1) to temp with (format csv, header false);"
cat temp >> erreurs.csv

# rajouter contrôle de cohérence B/BIS T/TER, mais une fois les noms de voie harmonisés
# vérifier aussi à quoi correspondent les F P et X en surnombre (DGFiP ? cf Paris)

