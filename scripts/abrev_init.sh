# création et mise à jour de la table des libellés

psql -c "
drop table if exists libelle;
create table libelle (long text, court text);
create index libelles_long on libelles (long);
create index libelles_court on libelles (court);
create index libelles_court_trgm on libelles using gist (court gist_trgm_ops);

-- libelles FANTOIR
insert into libelles (select lib_court as long, null as court from dgfip_fantoir left join libelles on (long=lib_court) where long is null group by 1,2);

-- libellés BAN (nom_voie)
insert into libelles (select upper(unaccent(nom_voie)) as long, null as court from ban_temp left join libelles on (long= upper(unaccent(nom_voie))) where long is null group by 1,2);

-- libellés BAN (nom_ld)
insert into libelles (select nom_ld as long, null as court from ban_temp left join libelles on (long=nom_ld) where long is null group by 1,2);

-- nettoyage libellés courts pour ne garder que lettres et chiffres
update libelles set court=regexp_replace(regexp_replace(long,'[^A-Z 0-9]',' ','g'),' +',' ','g') where court is null;
"
