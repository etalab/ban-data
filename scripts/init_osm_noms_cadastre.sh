# import des noms de voie extraits des plan cadastraux par les scripts BANO

zcat ../data/osm/noms_cadastre_win1252.csv.gz | iconv -f win1252 -t utf8 > noms_cadastre.csv

psql -c "drop dgfip_noms_cadastre if exists; create table dgfip_noms_cadastre (insee text, nom_cadastre text, fantoir text);"
psql -c "\copy dgfip_noms_cadastre from '../data/osm/noms_cadastre.csv' with (format csv, header true);"
psql -c "create index dgfip_noms_cadastre_fantoir on dgfip_noms_cadastre using spgist (fantoir);"

