echo "\n-- nombre de nom_voie vides ou nuls sans nom_ld (regroupés par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb_nom_vide, sum(case when id_fantoir!='' then 1 else 0 end) as avec_fantoir from ban_temp where nom_voie='' and nom_ld='' group by 1 order by 1;"

echo "\n-- nombre de nom_voie avec '/' (regroupés par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb, min(nom_voie) as exemple from ban_temp where nom_voie like '%/%' group by 1 order by 1;"

echo "\n-- nombre de nom_voie avec '/' et répétitions (regroupés par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb_total, sum(repete) as nb_repete, min(nom_voie) as exemple from (select code_insee, nom_voie, array_length(regexp_matches(nom_voie,'^(.*)/\1$'),1) as repete from ban_temp where nom_voie like '%/%') as r group by 1 order by 1;;"

echo "\n-- nombre de nom_voie différents avec id_fantoir identique (regroupés par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb, min(noms) as exemple from (select code_insee, id_fantoir, count(*) as nb_noms, sum(nb) as nb_adresses, left(string_agg(nom,' + '),100) as noms from (select code_insee, id_fantoir, format('"%s,%s"',nom_voie,nom_ld) as nom, count(*) as nb from ban_temp where id_fantoir !='' group by 1,2,3) as f group by 1,2) as f2 where nb_noms>1 group by 1 order by 1;"

echo "\n-- exemples de nom_voie différents avec id_fantoir identique\n"
psql -P pager -c "select code_insee, id_fantoir, count(*) as nb_noms, sum(nb) as nb_adresses, left(string_agg(nom,' + '),100) as noms from (select code_insee, id_fantoir, format('"%s,%s"',nom_voie,nom_ld) as nom, count(*) as nb from ban_temp where id_fantoir !='' group by 1,2,3) as f group by 1,2 order by 3 desc limit 50;"

echo "\n-- vérification erreurs courantes d'accentuation\n"
psql -P pager -c "select nom_voie, count(*) as nb from ban_temp where nom_voie ~ ' clémenceau' group by 1 order by 2 desc;"

echo "\n-- vérification chiffres romains en minuscule\n"
psql -P pager -c "select nom_voie, count(*) as nb from ban_temp where nom_voie ~ ' [ivx]*( |$)' and nom_voie !~ 'vi?[vx]' group by 1 order by 2 desc;"

echo "\n-- vérification de présence d'abbréviations résiduelles\n"
for a in `csvcut ../data/abbrev.txt --columns 1 | tail -n +2 | tr '[:upper:]' '[:lower:]' | tr '_' '\ '`
do
echo "  abrev: $a"
psql -P pager -c "
select nom_voie, count(*) as nb, left(string_agg(distinct(code_insee),','),60) as exemple from ban_temp where nom_voie ~ '(^| )$a( |$)' group by 1 order by 2 desc;
"
done

echo "\n-- vérification de présence d'abbréviations doublées\n"
psql -P pager -c "
select nom_voie, count(*) from ban_temp where nom_voie ~ '(^| )(chemin .*chem|grand.*gde)( |$)' group by 1 order by 2 desc;
"

echo "\n-- noms très longs\n"
psql -P pager -c "
select length(nom_voie) as longueur, nom_voie, code_insee, id_fantoir from ban_temp where length(nom_voie)>60 group by 1,2,3,4 order by 1 desc limit 50;
"


