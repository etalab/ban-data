# entête du fichier collecteur d'erreurs
# code_insee: code_insee indiqué dans le fichier d'origine
# id: id BAN de l'adresse à vérifier/corriger
# champs: liste des champs concernés séparés par '+'
# contenu: contenu du premier champ concerné
# erreur: descriptif textuel de l'erreur
# echo 'code_insee,id,champs,contenu,erreur' > erreurs.csv

source config.sh

echo "\n-- nombre de nom_voie vides ou nuls sans nom_ld (regroupés par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb_nom_vide, sum(case when id_fantoir!='' then 1 else 0 end) as avec_fantoir from ban_temp where nom_voie='' and nom_ld='' group by 1 order by 1;"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_voie+nom_ld','','nom_voie et nom_ld vide' from ban_temp where nom_voie='' and nom_ld=''" >> erreurs.csv

echo "\n-- nom_voie contient nom_ld\n"
psql -c "\copy (select b.code_insee, b.id, 'nom_voie+nom_ld',b.nom_voie,'nom_voie contient nom_ld' from ban_temp b join ban_temp c on (c.id=b.id) where b.nom_voie !='' and c.nom_ld !='' and lower(unaccent(b.nom_voie)) like '%' || lower(unaccent(c.nom_ld)) || '%') to temp with (format csv, header false)"
cat temp >> erreurs.csv

echo "\n-- aucun nom ni code fantoir\n"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_voie+nom_ld+alias+id_fantoir','','aucun nom ni code fantoir' from ban_temp where nom_voie||nom_ld||alias||id_fantoir=''" >> erreurs.csv

echo "\n-- nombre de nom_voie avec '/' (regroupés par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb, min(nom_voie) as exemple from ban_temp where nom_voie like '%/%' group by 1 order by 1;"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_voie',nom_voie,'nom_voie contient /' from ban_temp where nom_voie ~ '\/'" >> erreurs.csv

echo "\n-- nombre de nom_voie avec '/' et répétitions (regroupés par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb_total, sum(repete) as nb_repete, min(nom_voie) as exemple from (select code_insee, nom_voie, array_length(regexp_matches(nom_voie,'^(.*)/\1$'),1) as repete from ban_temp where nom_voie like '%/%') as r group by 1 order by 1;"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_voie',nom_voie,'nom_voie contient / avec valeurs repetees' from ban_temp where nom_voie ~ '^(.*)/\1$' " >> erreurs.csv

echo "\n-- nombre de nom_voie différents avec id_fantoir identique (regroupés par département)\n"
psql -P pager -c "select left(code_insee,2) as dept, count(*) as nb, min(noms) as exemple from (select code_insee, id_fantoir, count(*) as nb_noms, sum(nb) as nb_adresses, left(string_agg(nom,' + '),100) as noms from (select code_insee, id_fantoir, format('%s;%s',nom_voie,nom_ld) as nom, count(*) as nb from ban_temp where id_fantoir !='' group by 1,2,3) as f group by 1,2) as f2 where nb_noms>1 group by 1 order by 1;"

echo "\n-- exemples de nom_voie différents avec id_fantoir identique\n"
psql -P pager -c "select code_insee, id_fantoir, count(*) as nb_noms, sum(nb) as nb_adresses, left(string_agg(nom,' + '),100) as noms from (select code_insee, id_fantoir, format('"%s,%s"',nom_voie,nom_ld) as nom, count(*) as nb from ban_temp where id_fantoir !='' group by 1,2,3) as f group by 1,2 order by 3 desc limit 50;"

echo "\n-- vérification erreurs courantes d'accentuation\n"
psql -P pager -c "select nom_voie, count(*) as nb from ban_temp where nom_voie ~ ' (clémenceau|geneve|du fosse|gabriel peri)( |$)' group by 1 order by 2 desc;"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_voie',nom_voie,'erreur accentuation' from ban_temp where nom_voie ~ ' (clémenceau|geneve|du fosse|gabriel peri)( |$)' " >> erreurs.csv

echo "\n-- vérification chiffres romains en minuscule\n"
psql -P pager -c "select nom_voie, count(*) as nb from ban_temp where nom_voie ~ ' [ivx]*( |$)' and nom_voie !~ 'vi?[vx]' group by 1 order by 2 desc;"

echo "\n-- vérification de présence d'abbréviations résiduelles\n"
for a in `csvcut ../data/abbrev.txt --columns 1 | tail -n +2 | tr '[:upper:]' '[:lower:]' | tr '_' '\ ' | sort -u`
do
echo "  abrev: $a"
# psql -P pager -c "select nom_voie, count(*) as nb, left(string_agg(distinct(code_insee),','),60) as exemple from ban_temp where nom_voie ~ '(^| )$a( |$)' group by 1 order by 2 desc;"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_voie',nom_voie,'abbreviation residuelle: $a' from ban_temp where nom_voie ~ '(^| )$a( |$)' " >> erreurs.csv
done

echo "\n-- vérification de présence d'abbréviations doublées\n"
psql -P pager -c "
select nom_voie, count(*) from ban_temp where nom_voie ~ '(^| )(ancien.* anc|route .* (route|rte)|chemin .*chem(in|)|grand.*(gde|grande))( |$)' and NOT nom_voie ~ '/' group by 1 order by 2 desc;
"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_voie',nom_voie,'abbreviation residuelle doublee' from ban_temp where nom_voie ~ '(^| )(ancien.* anc|route .* (route|rte)|chemin .*chem(in|)|grand.*(gde|grande))( |$)' and NOT nom_voie ~ '/' " >> erreurs.csv

echo "\n-- noms très longs\n"
psql -P pager -c "
select length(nom_voie) as longueur, nom_voie, code_insee, id_fantoir from ban_temp where length(nom_voie)>60 group by 1,2,3,4 order by 1 desc limit 50;
"

echo "\n-- noms comportant des parenthèses\n"
psql -P pager -c "
select nom_voie, left(string_agg(distinct(code_insee),','),60) as exemple from ban_temp where nom_voie ~ '\(' or nom_voie ~ '\)' group by 1 order by 1;
"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_voie',nom_voie,'nom comportant des parentheses' from ban_temp where nom_voie ~ '\(' or nom_voie ~ '\)' " >> erreurs.csv

echo "\n-- noms comportant des tirets\n"
psql -P pager -c "
select nom_voie, left(string_agg(distinct(code_insee),','),60) as exemple from ban_temp where nom_voie ~ ' -' or nom_voie ~ '- ' or nom_voie ~ '--' group by 1 order by 1;
"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_voie',nom_voie,'nom comportant des tirets' from ban_temp where nom_voie ~ ' -' or nom_voie ~ '- ' or nom_voie ~ '--' " >> erreurs.csv

echo "\n-- noms comportant des |\n"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_voie',nom_voie,'nom comportant des |' from ban_temp where nom_voie LIKE '%|%' " >> erreurs.csv

echo "\n-- noms comportant des caractères étranges\n"
psql -P pager -c "
select nom_voie, left(string_agg(distinct(code_insee),','),60) as exemple from ban_temp where lower(unaccent(nom_voie)) !~ '[a-z0-9\-\/\(\)]' group by 1 order by 1;
"
sql2csv --db "$DB" -H --query "select code_insee,id,'nom_voie',nom_voie,'nom comportant des caracteres non alpha-num' from ban_temp where nom_voie !='' and replace(lower(unaccent(nom_voie)),chr(39),'') ~ '[^a-z0-9\-\/\(\) °]'" >> erreurs.csv


echo "\n-- nom_voie identique nom_ld"
psql -c "\copy (select code_insee,id,'nom_voie',nom_voie,'nom_voie et nom_ld identiques : '||nom_ld from ban_temp where nom_ld !='' and unaccent(lower(nom_voie))=unaccent(lower(nom_ld))) to temp with (format csv, header false);"; cat temp >> erreurs.csv

echo "\n-- nom_voie et alias identiques"
psql -c "\copy (select code_insee,id,'nom_voie',nom_voie,'nom_voie et alias identiques : '||alias from ban_temp where alias !='' and unaccent(lower(nom_voie))=unaccent(lower(alias))) to temp with (format csv, header false);"; cat temp >> erreurs.csv

echo "\n-- nom_ld et alias identiques"
psql -c "\copy (select code_insee,id,'nom_ld',nom_ld,'nom_ld et alias identiques : '||alias from ban_temp where nom_ld !='' and replace(lower(unaccent(nom_ld)),'-',' ')=replace(lower(unaccent(alias)),'-',' ')) to temp with (format csv, header false);"; cat temp >> erreurs.csv

echo "\n-- nom_ld avec premier mot doublé"
psql -c "\copy (select code_insee,id,'nom_ld',nom_ld,'nom_ld avec premier mot double' from ban_temp where nom_ld !='' and nom_ld ~ '^([A-Z]*) \1( |$)') to temp with (format csv, header false);"; cat temp >> erreurs.csv

echo "\n-- nom_voie vide, nom_ld present et FANTOIR indique LD"
psql -c "\copy (select code_insee,id,'nom_ld',nom_ld,'nom_voie vide + nom_ld present + FANTOIR indique LD' from ban_temp where nom_voie='' and nom_ld !='' and id_fantoir LIKE 'B%') to temp with (format csv, header false);"; cat temp >> erreurs.csv

echo "\n-- nom_ld absence probable d'apostrophe apres D,L,QU,PRESQU"
psql -c "\copy (select code_insee,id,'nom_ld',nom_ld,'absence apostrophe probable' from ban_temp where nom_ld !='' and nom_ld ~ '(^| )(D|L|QU|PRESQU) [AEIOUYH]') to temp with (format csv, header false);"; cat temp >> erreurs.csv
psql -c "\copy (select code_insee,id,'nom_ld',nom_ld,'absence apostrophe probable' from ban_temp where nom_ld !='' and nom_ld ~ ' S IL ') to temp with (format csv, header false);"; cat temp >> erreurs.csv

echo "-- nom_ld semble tronqué à 26 caractères"
psql -c "\copy (select code_insee, id, 'nom_ld',nom_ld,'nom_ld semble tronqué à 26 caractères' from ban_temp where length(nom_ld)=26 and nom_ld ~ ' ([A-Z]|[BCDFGHJKLMNPQRSTVWXZ][BCDFGHJKLMNPQRSTVWXZ])$' order by 1,4) to temp with (format csv, header false);"; cat temp >> erreurs.csv

echo "\n-- nom_voie commence par 'Enceinte' et nom_ld par 'EN '"
psql -c "\copy (select code_insee,id,'nom_voie',nom_voie,'erreur probable de desabreviation : '||nom_ld from ban_temp where nom_voie ilike 'ENCEINTE %' and nom_ld LIKE 'EN %') to temp with (format csv, header false);"; cat temp >> erreurs.csv

echo "\n-- nom_voie commence par 'sentier' et nom_afnor par 'SENTE '"
psql -c "\copy (select code_insee,id,'nom_voie',nom_voie,'erreur probable de desabreviation : '||nom_afnor from ban_temp where nom_afnor ILIKE 'SENTE %' and nom_voie ilike 'SENTIER %') to temp with (format csv, header false);"; cat temp >> erreurs.csv

echo "\n-- test cohérence type voie entre nom_voie et nom_afnor"
psql -c "\copy (select code_insee,id,'nom_voie',nom_voie,'incohérence de type de voie nom_voie/nom_afnor : '||nom_afnor from ban_temp where nom_afnor !='' and nom_afnor not like 'LIEU DIT%' and nom_afnor not like 'HAMEAU %' and split_part(upper(unaccent(replace(nom_voie,chr(39),' '))),' ',1) != split_part(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(nom_afnor,'^ALL ','ALLEE '),'^AV ','AVENUE '),'^BD ','BOULEVARD '),'^CTRE ','CENTRE '),'^IMM ','IMMEUBLE '),'^IMP ','IMPASSE '),'^LOT ','LOTISSEMENT '),'^PAS ','PASSAGE '),'^PL ','PLACE '),'^RES ','RESIDENCE '),'^RPT ','ROND-POINT '),'^ROND POINT ','ROND-POINT '),'^RTE ','ROUTE '),'^SQ ','SQUARE '),'^VLGE ','VILLAGE '),' ',1)) to temp with (format csv, header false);"; cat temp >> erreurs.csv

echo "-- nom_afnor introuvable dans hexavia"
psql -c "\copy (select b.code_insee, b.id, 'nom_afnor', b.nom_afnor, 'nom_afnor introuvable dans hexavia' from (select n.* from (select code_insee, nom_afnor from ban_temp where nom_afnor!='' group by 1,2) as n left join poste_hexavia v on (v.insee=n.code_insee and v.lib_voie=n.nom_afnor) where v.insee is null) as m join ban_temp b on (b.code_insee=m.code_insee and b.nom_afnor=m.nom_afnor)) to temp with (format csv, header false);"; cat temp >> erreurs.csv

