# import de la liste des codes postaux

mkdir ../data/poste/
cd ../data/poste/

wget -O codes_postaux.csv "https://datanova.legroupe.laposte.fr/explore/dataset/laposte_hexasmal/download/?format=csv"
psql -c "drop table if exists poste_cp; create table poste_cp (insee text, commune text, cp text, libelle text ligne5 text, coords text);"
psql -c "\copy poste_cp from codes_postaux.csv with (format csv, header true, delimiter ';');"
psql -c "
create index poste_cp_insee on poste_cp using spgist (insee);
create index poste_cp_cp on poste_cp using spgist (cp);
"
