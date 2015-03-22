# import de la liste des codes postaux
# c'est une version corrigée qui est utilisée, le fichier officiel sur data.gouv.fr comportant des erreurs

cd ../data/poste/
wget -nc https://www.data.gouv.fr/s/resources/base-officielle-des-codes-postaux/community/20150308-152148/code_postaux_v201410_corr.csv

# import dans postgres
psql -c "drop table if exists poste_cp; create table poste_cp (insee text, commune text, cp text, libelle text);"
psql -c "\copy poste_cp from code_postaux_v201410_corr.csv with (format csv, header true, encoding 'iso8859-1', delimiter ';');"
psql -c "
create index poste_cp_insee on poste_cp using spgist (insee);
create index poste_cp_cp on poste_cp using spgist (cp);
"


