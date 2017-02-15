# récupération et décompression du fichier FANTOIR sur data.gouv.fr via son API

URL=`http 'https://www.data.gouv.fr/api/1/datasets/53699580a3a729239d204738/' | jq '.resources|sort_by(.published)|.[].url' -r | tail -n 1`
FANTOIR=`echo $URL | sed 's".*/"";s".zip""'`

cd ../data/dgfip
wget -nc $URL
unzip -u $FANTOIR.zip

# import dans SQL en format fixe (delimiter et quote spéciaux pour ignorer)
psql -c "create table if not exists dgfip_fantoir_temp (raw text); truncate dgfip_fantoir_temp;"
psql -c "\copy dgfip_fantoir_temp from '$FANTOIR' with csv delimiter '#' quote '>';"
psql -c "
drop table if exists $FANTOIR;
create table $FANTOIR as (select substr(raw,1,2)||substr(raw,4,3)||'_'||substr(raw,7,4)||substr(raw,11,1) as fantoir, substr(raw,1,2) as code_dept, substr(raw,3,1) as code_dir, substr(raw,4,3) as code_com, substr(raw,1,2)||substr(raw,4,3) as code_insee, substr(raw,7,4) as id_voie, substr(raw,11,1) as cle_rivoli, rtrim(substr(raw,12,4)) as nature_voie, rtrim(substr(raw,16,26)) as libelle_voie,  substr(raw,49,1) as type_commune, substr(raw,50,1) as caractere_rur, substr(raw,51,1) as caractere_voie, substr(raw,52,1) as caractere_pop, substr(raw,60,7)::integer as pop_a_part, substr(raw,67,7)::integer as pop_fictive, substr(raw,74,1) as caractere_annul, substr(raw,75,7) as date_annul, substr(raw,82,7) as date_creation, substr(raw,104,5) as code_majic, substr(raw,109,1) as type_voie, substr(raw,110,1) as ld_bati, trim(substr(raw,113,8)) as dernier_mot from dgfip_fantoir_temp where raw not like '______ %' and raw not like '___ %');

-- plus besoin de la table fantoir "RAW"
drop table dgfip_fantoir_temp;

-- préparation libelle court pour les appariements
alter table $FANTOIR add lib_court text;
update $FANTOIR set lib_court=regexp_replace(regexp_replace(upper(unaccent(trim(nature_voie||' '||libelle_voie))),'[^A-Z 0-9]',' ','g'),' +',' ','g');

-- ajout des index et clustering de la table pour les perfs globales
create index idx_insee_$FANTOIR on $FANTOIR (code_insee,id_voie) with (fillfactor=100);
create index idx_lib_$FANTOIR on $FANTOIR  (lib_court, code_insee);
cluster $FANTOIR using idx_insee_$FANTOIR;

-- la nouvelle table remplace l'ancienne (via une VIEW)
CREATE OR REPLACE VIEW dgfip_fantoir as select * from $FANTOIR;
"
