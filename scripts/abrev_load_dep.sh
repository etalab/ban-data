# création et mise à jour de la table des libellés

psql -c "
-- libellés BAN_odbl (nom_voie)
insert into libelles (select upper(unaccent(nom_voie)) as long, null as court from ban_group_$1 left join libelles on (long= upper(unaccent(nom_voie))) where nom_voie != '' and long is null group by 1,2);

-- libellés BAN_odbl (nom_ld)
insert into libelles (select nom_ld as long, null as court from ban_group_$1 left join libelles on (long=nom_ld) where nom_ld != '' and long is null group by 1,2);

--
update libelles set court=regexp_replace(regexp_replace(long,'[^A-Z 0-9]',' ','g'),' +',' ','g') where court is null;
"
