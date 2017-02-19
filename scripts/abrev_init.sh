# création et mise à jour de la table des libellés

psql -c "
create table if not exists libelles (long text, court text,status text);
create index libelles_long on libelles (long);
create index libelles_court on libelles (court);
create index libelles_court_trgm on libelles using gist (court gist_trgm_ops);
create index libelles_status on libelles (status) where status is null;

-- libelles FANTOIR
insert into libelles (select lib_court as long, regexp_replace(regexp_replace(lib_court,'[^A-Z 0-9]',' ','g'),' +',' ','g') as court, null as status from dgfip_fantoir group by 1,2);

"
# on lance la mise à jour pour FANTOIR
sh abrev_update.sh

# on marque les libellés FANTOIR comme traités
psql -c "UPDATE libelles SET status='ok' WHERE status is null; ANALYSE libelles;"
