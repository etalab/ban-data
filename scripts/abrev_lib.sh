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

# mise à jour des abréviations à appliquer
psql -c "TRUNCATE table abbrev;"
psql -c "\copy abbrev from ../data/abbreviations.csv WITH (FORMAT CSV, HEADER TRUE)"

# suppression des mot doublés
psql -c "UPDATE libelles SET court=regexp_replace(court,' ([A-Z0-9]+) \1 ',' \1 ','g') WHERE court ~ ' ([A-Z0-9]+) \1 ';"

# génération et exécution de requêtes UPDATE
psql -Atc "select format(E'UPDATE libelles SET court=regexp_replace(court,\'%s\',\'%s\') WHERE court ~ \'%s \';', '(^| )'||txt_long||' ', '\1'||txt_court||' ',txt_long) from abbrev WHERE txt_long!=txt_court order by length(txt_long) desc;" | psql

# suppression des articles
psql -c "UPDATE libelles SET court=regexp_replace(court,' (DE|DU|DE LA|DE L|D|L|DES|AU|AUX|A|ET|DIT|DITE|EN) ',' ','g') WHERE court ~ ' (DE|DU|DE LA|DE L|D|L|DES|AU|AUX|A|ET|DIT|DITE|EN) ';"
psql -c "UPDATE libelles SET court=regexp_replace(court,' (DE|DU|DE LA|DE L|D|L|DES|AU|AUX|A|ET|DIT|DITE|EN) ',' ','g') WHERE court ~ ' (DE|DU|DE LA|DE L|D|L|DES|AU|AUX|A|ET|DIT|DITE|EN) ';"
psql -c "UPDATE libelles SET court=regexp_replace(court,' (DE|DU|DE LA|DE L|D|L|DES|AU|AUX|A|ET|DIT|DITE|EN) ',' ','g') WHERE court ~ ' (DE|DU|DE LA|DE L|D|L|DES|AU|AUX|A|ET|DIT|DITE|EN) ';"

# simplification des XXième, ème, er...
psql -c "UPDATE libelles SET court=regexp_replace(court,' ([0-9]+)(IE|E)[A-Z]+ ',' \1E ','g') WHERE court ~ ' ([0-9]+)(IE|E)[A-Z]+ ';"
psql -c "UPDATE libelles SET court=regexp_replace(court,' ([0-9]+)(IE|E)[A-Z]+ ',' \1E ','g') WHERE court ~ ' ([0-9]+)(IE|E)[A-Z]+ ';"
