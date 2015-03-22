# récupération et décompression du fichier FANTOIR
# wget http://www2.impots.gouv.fr/documentation/fantoir/fichier_national_fantoir.zip
cd ../data/dgfip
unzip FANTOIR0115.zip

# import dans SQL en format fixe (delimiter et quote spéciaux pour ignorer)
psql -c "create table if not exists dgfip_fantoir_temp (raw text);"
psql -c "\copy dgfip_fantoir_temp from 'FANTOIR0115' with csv delimiter '#' quote '>';"
psql -c "
drop table dgfip_fantoir;
create table dgfip_fantoir as (select substr(raw,1,2)||substr(raw,4,3)||'_'||substr(raw,7,4)||substr(raw,11,1) as fantoir, substr(raw,1,2) as code_dept, substr(raw,3,1) as code_dir, substr(raw,4,3) as code_com, substr(raw,1,2)||substr(raw,4,3) as code_insee, substr(raw,7,4) as id_voie, substr(raw,11,1) as cle_rivoli, rtrim(substr(raw,12,4)) as nature_voie, rtrim(substr(raw,16,26)) as libelle_voie,  substr(raw,49,1) as type_commune, substr(raw,50,1) as caractere_rur, substr(raw,51,1) as caractere_voie, substr(raw,52,1) as caractere_pop, substr(raw,60,7)::integer as pop_a_part, substr(raw,67,7)::integer as pop_fictive, substr(raw,74,1) as caractere_annul, substr(raw,75,7) as date_annul, substr(raw,82,7) as date_creation, substr(raw,104,5) as code_majic, substr(raw,109,1) as type_voie, substr(raw,110,1) as ld_bati, trim(substr(raw,113,8)) as dernier_mot from dgfip_fantoir_temp where raw not like '______ %' and raw not like '___ %');
create index dgfip_fantoir_insee on dgfip_fantoir using spgist (fantoir) with (fillfactor=100);
create index dgfip_fantoir_fantoir on dgfip_fantoir (fantoir) with (fillfactor=100);
drop table dgfip_fantoir_temp;
"


