# import de la liste des codes postaux

mkdir -p ../data/poste/
cd ../data/poste/

wget -O codes_postaux.csv "https://datanova.legroupe.laposte.fr/explore/dataset/laposte_hexasmal/download/?format=csv"
psql -c "drop table if exists poste_cp; create table poste_cp (insee text, commune text, cp text, libelle text, ligne5 text, coords text);"
psql -c "\copy poste_cp from codes_postaux.csv with (format csv, header true, delimiter ';');"
psql -c "
create index poste_cp_insee on poste_cp using spgist (insee);
create index poste_cp_cp on poste_cp using spgist (cp);
"

wget -O codes_postaux_fusions.csv "https://datanova.laposte.fr/explore/dataset/laposte_commnouv/download/?format=csv"
psql -c "drop table if exists poste_cp_fusions; create table poste_cp_fusions (mep_ran text, insee text, commune_deleguee text, insee_2016 text, insee_2015 text, libelle_acheminenent_2015 text, nom_commune_nouvelle_siege text, code_insee_commune_deleguee_non_actif text, adresse_2016_l6_code_postal text, adresse_2016_l6_libelle_acheminement text, adresse_2016_ligne_5_commune_deleguee text, adresse_2016_code_insee_associe_a_la_l5 text, adresse_2015_l6_code_postal text, adresse_2015_l5 text, adresse_2015_code_insee_associe_a_la_l5 text);"
psql -c "\copy poste_cp_fusions from codes_postaux_fusions.csv with (format csv, header true, delimiter ';');"
psql -c "
create index poste_cp_fusions_insee on poste_cp_fusions using spgist (insee);
"
