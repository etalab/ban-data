echo "\n-- nombre de nom_voie vides ou nuls sans nom_ld (regroupés par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb_nom_vide, sum(case when id_fantoir!='' then 1 else 0 end) as avec_fantoir from ban_temp where nom_voie='' and nom_ld='' group by 1 order by 1;"

echo "\n-- nombre de nom_voie avec '/' (regroupés par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb, min(nom_voie) as exemple from ban_temp where nom_voie like '%/%' group by 1 order by 1;"

echo "\n-- nombre de nom_voie avec '/' et répétitions (regroupés par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb_total, sum(repete) as nb_repete, min(nom_voie) as exemple from (select code_insee, nom_voie, array_length(regexp_matches(nom_voie,'^(.*)/\1$'),1) as repete from ban_temp where nom_voie like '%/%') as r group by 1 order by 1;;"

echo "\n-- nombre de nom_voie différents avec id_fantoir identique (regroupés par département)\n"

