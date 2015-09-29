/* on remplit la table "manque" avec les adresses HEXA absente de la BAN */
drop table if exists manque;

create table manque as select ''::text as cia, 0 as lat, 0 as lon, c.numero, c.extension, cea from poste_hexavia v join poste_hexacle c on (v.matricule_voie=c.matricule and c.numero !='') left join ban_temp b on (b.code_insee=v.insee and b.nom_afnor=v.lib_voie and b.numero=c.numero and b.rep=c.extension) where b.id is null group by 1,2,3,4,5,6;
create index manque_cea on manque (cea);
create index manque_cia on manque (cia);

/* décomptes des adresses RAN manquantes dans la BAN, par département */
select case when left(insee,2) in ('97','99') then left(insee,3) else left(insee,2) end as dep, count(distinct(m.cea)) as nb from manque m join poste_hexacle c on (c.cea=m.cea) join poste_hexavia v on (matricule=matricule_voie) where m.numero !='' group by 1;


drop table if exists manque_voie =;
create table manque_voie as select v.insee, v.matricule_voie as matricule, v.lib_voie, v.dernier_mot, ''::text as nom_court, ''::text as fantoir from manque m join poste_hexacle c on (c.cea=m.cea) join poste_hexavia v on (matricule=matricule_voie) group by 1,2,3,4,5,6;
create index manque_voie_insee on manque_voie (insee);

/* mise à jour code FANTOIR sur les libellés identiques */
with u as (select f.fantoir, m.matricule from manque_voie m join dgfip_fantoir f on (f.code_insee=m.insee AND f.date_annul='0000000' AND m.lib_voie=trim(f.nature_voie||' '||f.libelle_voie)) group by 1,2) update manque_voie m set fantoir=u.fantoir from u where m.fantoir='' and m.matricule=u.matricule ;


/* élimination des LIEU-DIT tirets et apostrophes */
update manque_voie set nom_court=regexp_replace(replace(replace(regexp_replace(lib_voie,'^LIEU DIT ',''),'-',' '),chr(39),' '),' +',' ','g');

/* mise à jour FANTOIR */
with u as (select f.fantoir, m.matricule from manque_voie m join dgfip_fantoir f on (f.code_insee=m.insee AND f.date_annul='0000000' and m.nom_court=f.lib_court) group by 1,2) update manque_voie m set fantoir=u.fantoir from u where m.fantoir='' and m.matricule=u.matricule ;

/* calcul de noms courts en appliquant les abbréviations connues (table abbrev) */
with u as (select * from abbrev where txt_long != txt_court ORDER BY length(txt_long) DESC) update manque_voie set nom_court=regexp_replace(nom_court,'(^| )'||txt_long||'( |$)','\1'||txt_court||'\2','g') from u where nom_court ~ ('(^| )'||txt_long||'( |$)') ;
with u as (select * from abbrev where txt_long != txt_court ORDER BY length(txt_long) DESC) update manque_voie set nom_court=regexp_replace(nom_court,'(^| )'||txt_long||'( |$)','\1'||txt_court||'\2','g') from u where nom_court ~ ('(^| )'||txt_long||'( |$)') ;
with u as (select * from abbrev where txt_long != txt_court ORDER BY length(txt_long) DESC) update manque_voie set nom_court=regexp_replace(nom_court,'(^| )'||txt_long||'( |$)','\1'||txt_court||'\2','g') from u where nom_court ~ ('(^| )'||txt_long||'( |$)') ;

/* mise à jour FANTOIR */
with u as (select f.fantoir, m.matricule from manque_voie m join dgfip_fantoir f on (f.code_insee=m.insee AND f.date_annul='0000000' and m.nom_court=f.lib_court) group by 1,2) update manque_voie m set fantoir=u.fantoir from u where m.fantoir='' and m.matricule=u.matricule ;

/* suppression des mots non signifiants (LE, LA, LES, etc) */
update manque_voie set nom_court=trim(regexp_replace(regexp_replace(nom_court,'(^| )(L|LE|LA|LES|D|DE|DU|DES|AU|AUX)( |$)',' ','g'),'(^| )(L|LE|LA|LES|D|DE|DU|DES|AU|AUX)( |$)',' ','g')) where nom_court ~ '(^| )(L|LE|LA|LES|D|DE|DU|DES|AU|AUX)( |$)';

/* mise à jour FANTOIR sans les mots non signifiants */
with u as (select f.fantoir, m.matricule from manque_voie m join dgfip_fantoir f on (f.code_insee=m.insee AND f.date_annul='0000000' and m.nom_court=regexp_replace(regexp_replace(f.lib_court,'(^| )(L|LE|LA|LES|D|DE|DU|DES|AU|AUX)( |$)',' ','g'),'(^| )(L|LE|LA|LES|D|DE|DU|DES|AU|AUX)( |$)',' ','g')) group by 1,2) update manque_voie m set fantoir=u.fantoir from u where m.fantoir='' and m.matricule=u.matricule ;

/* mise à jour lat/lon */
with u as (select v.fantoir, m.cea, a.cia, a.lat, a.lon from manque_voie v join poste_hexacle c on (c.matricule=v.matricule) join manque m on (m.cea=c.cea) join dgfip_adresses a on (a.cia = v.fantoir||'_'|| replace(trim(m.numero||' '||m.extension),' ','_')) where v.fantoir!='' group by 1,2,3,4,5) update manque m set cia=u.cia, lat=u.lat, lon=u.lon from u where m.cea=u.cea;

