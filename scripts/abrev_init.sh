# création et mise à jour de la table des libellés

psql -c "
drop table if exists libelles;
create table libelles (long text, court text);
create index libelles_long on libelles (long);
create index libelles_court on libelles (court);
create index libelles_court_trgm on libelles using gist (court gist_trgm_ops);

-- libelles FANTOIR
insert into libelles (select lib_court as long, regexp_replace(regexp_replace(lib_court,'[^A-Z 0-9]',' ','g'),' +',' ','g') as court from dgfip_fantoir group by 1,2);

"

# mise à jour des abréviations à appliquer
psql -c "TRUNCATE table abbrev;"
psql -c "\copy abbrev from ../data/abbreviations.csv WITH (FORMAT CSV, HEADER TRUE)"

# on lance la mise à jour pour FANTOIR
sh abrev_update.sh
