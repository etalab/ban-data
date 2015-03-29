# contrôle de cohérence et détection d'erreurs et anomalies sur la colonne id_fantoir

# chaine de connexion à la base postgres locale
DB=postgresql:///cquest

echo "\n-- id_fantoir est vide (groupé par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb, sum(case when nom_voie||nom_ld||alias='' then 1 else 0 end) as nb_sans_nom from ban_temp where id_fantoir='' group by 1 order by 1;"
sql2csv --db "$DB" -H --query "select code_insee,id,'id_fantoir','','id_fantoir est vide' from ban_temp where id_fantoir=''" >> erreurs.csv

echo "\n-- id_fantoir inconnu\n"
sql2csv --db "$DB" -H --query "select b.code_insee, b.id, 'id_fantoir',b.id_fantoir,'id_fantoir inconnu' from ban_temp b left join dgfip_fantoir f on (f.code_insee=b.code_insee and f.id_voie=b.id_fantoir) where f.id_voie is null and b.id_fantoir !=''" >> erreurs.csv

echo "\n-- id_fantoir annulé/obsolète (groupé par département)\n"
psql -P pager -c "select left(b.code_insee,2) as dept, count(*) as nb, min(left(f.date_annul,4)) as annee_min, max(left(f.date_annul,4)) as annee_max from ban_temp b left join dgfip_fantoir f on (f.code_insee=b.code_insee and f.id_voie=b.id_fantoir) where f.date_annul!='0000000' and b.id_fantoir !='' group by 1 order by 1;"
sql2csv --db "$DB" -H --query "select b.code_insee, b.id, 'id_fantoir',b.id_fantoir,'id_fantoir annule/obsolete depuis '||left(f.date_annul,4) from ban_temp b left join dgfip_fantoir f on (f.code_insee=b.code_insee and f.id_voie=b.id_fantoir) where f.date_annul!='0000000' and b.id_fantoir !=''" >> erreurs.csv

echo "\n-- nom de voie+ld+alias ne contient pas le dernier mot FANTOIR\n"
psql -c "\copy (select b.code_insee, b.id,'nom_voie+id_fantoir', nom_voie, format('nom ne contient pas dernier mot fantoir: %s (%s)',f.dernier_mot,trim(f.nature_voie||' '||f.libelle_voie)) from ban_temp b join dgfip_fantoir f on (f.code_insee=b.code_insee and f.id_voie=b.id_fantoir) where b.id_fantoir!='' and NOT upper(unaccent(b.nom_voie||' '||b.nom_ld||' '||alias)) ~ replace(f.dernier_mot,'*','')) to temp with (format csv, header false)"
cat temp >> erreurs.csv

