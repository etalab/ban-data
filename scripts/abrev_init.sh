# création et mise à jour de la table des libellés

echo "Import libellés FANTOIR"
psql -c "
create table if not exists libelles (long text, court text, status text);
truncate libelles;
create index libelles_long on libelles (long);
create index libelles_court on libelles (court);
create index libelles_court_trgm on libelles using gist (court gist_trgm_ops) where status is null;

-- libelles FANTOIR
insert into libelles (select lib_court as long, regexp_replace(regexp_replace(lib_court,'[^A-Z 0-9]',' ','g'),' +',' ','g') as court, null as status from dgfip_fantoir group by 1,2);
"

# mise à jour liste des abréviations
psql -c "CREATE TABLE IF NOT EXISTS abbrev (txt_long text, txt_court text); TRUNCATE TABLE abbrev;"
psql -c "\COPY abbrev FROM ../data/abbreviations.csv WITH (format csv, header true);"

echo "Mise à jour libellés courts FANTOIR"
# on lance la mise à jour pour FANTOIR
sh abrev_update.sh

# on marque les libellés FANTOIR comme traités
psql -c "UPDATE libelles SET status='ok' WHERE status is null; ANALYSE libelles;"
