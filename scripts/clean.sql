-- script de mise à jour, correction et harmonisation des données

-- code_post: "code_post est vide"
with u as (select id, code_insee, code_post, string_agg(distinct(p.cp),',') as cp, count(distinct(p.cp)) as nb from ban_temp b left join poste_cp c on (c.cp=b.code_post) join poste_cp p on (p.insee=b.code_insee) where c.cp is null group by 1,2,3) update ban_temp b set code_post=u.cp from u where b.id=u.id and nb=1;

-- nom_voie: "nom_voie contient / avec valeurs repetees"
with u as (select id as u_id,regexp_replace(nom_voie,'^(.*)/\1$','\1') as u_nom from ban_temp where nom_voie ~ '^(.*)/\1$') update ban_temp set nom_voie=u_nom from u where id=u_id;

-- nom_voie=nom1/nom2 + alias vide -> nom_voie=nom1 alias=nom2
with u as (select id as u_id, left(nom_voie, position('/' in nom_voie)-1) as u_nom1, substring(nom_voie, position('/' in nom_voie)+1) as u_nom2 from ban_temp where nom_voie ~ '\/' and NOT nom_voie ~ '\/.*\/' and alias='') update ban_temp set nom_voie=u_nom1, alias=u_nom2 from u where id=u_id and alias='';

-- désabréviations...
update ban_temp set nom_voie=regexp_replace(nom_voie,'^brtl ','bretelle ') where nom_voie like 'brtl %';

-- ch/che/chem ambiguité avec chemin, cheminement
-- update ban_temp set nom_voie=regexp_replace(nom_voie,'^ch ','chemin ') where nom_voie like 'ch %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^rlle ','ruelle ') where nom_voie like 'rlle %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' grd ',' grand ') where nom_voie like '% grd %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^ache ','ancien chemin ') where nom_voie like 'ache %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^cr ','chemin rural ') where nom_voie like 'cr %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' av ',' avenue ') where nom_voie like '% avenue %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^cc ','chemin communal ') where nom_voie like 'cc %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^ancienne route ancienne rte ','ancienne route ') where nom_voie like 'ancienne route ancienne rte %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^ancien chemin ancien chem ','ancien chemin ') where nom_voie like 'ancien chemin ancien chem %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^lot ','lotissement ') where nom_voie like 'lot %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^gpl ','grand place ') where nom_voie like 'gpl %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^grand place gd pce ','grand place ') where nom_voie like 'grand place gd pce %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^rd pt ','rond-point ') where nom_voie like 'rd pt %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' all d',' allée d') where nom_voie like '% all d%';
-- CAE => CARRER/CARRIERA ?
update ban_temp set nom_voie=regexp_replace(nom_voie,' cht ',' château ') where nom_voie like '% cht %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' crs ',' cours ') where nom_voie like '% crs %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' crx ',' croix ') where nom_voie like '% crx %';
-- DOM => DOM/DOMAINE ?
update ban_temp set nom_voie=regexp_replace(nom_voie,'^dra ','draille ') where nom_voie like 'dra %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^draille draille ','draille ') where nom_voie like 'draille draille %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' dra ',' draille ') where nom_voie like '% dra %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^dsct ','descente ') where nom_voie like 'dsct %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' esc ',' escalier ') where nom_voie like '% esc %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^rue fg ','rue du faubourg ') where nom_voie like 'rue fg %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' fg ',' faubourg ') where nom_voie like '% fg %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^rue fbg ','rue du faubourg ') where nom_voie like 'rue fbg %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' fbg ',' faubourg ') where nom_voie like '% fbg %';
-- FON/FONT ambiguité FON/FONT/FONTAINE
update ban_temp set nom_voie=regexp_replace(nom_voie,' du foss ',' du fossé ') where nom_voie like '% du foss %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' gal (de |leclerc|daugan|chanzy|giraud|labat|paul|fauchon|le co|guillaumat|bruy|vuillemin|charles|delfino|duch|maurice|grazi|margue|soule|combelle|dubois|sir|duval)',' général \1') where nom_voie like '% gal %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^grp ','groupe ') where nom_voie like 'grp %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^hab ','habitat ') where nom_voie like 'hab %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' hab ',' habitat ') where nom_voie like '% hab %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' ham ',' hameaux ') where nom_voie like '%s ham %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' ham ',' hameau ') where nom_voie like '% ham %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' imp ',' impasse ') where nom_voie like '% imp %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'impasse impasse ','impasse ') where nom_voie like '%impasse impasse %';
-- JARD
update ban_temp set nom_voie=regexp_replace(nom_voie,'résidence lot ','résidence lotissement ') where nom_voie like 'résidence lot %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' lot (d|l)',' lotissement \1') where nom_voie like '% lot %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(rue|du) lot ','\1 lotissement ') where nom_voie like '% lot %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'lotissement lot ','lotissement ') where nom_voie like '%lotissement lot %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^mais ','maison ') where nom_voie like 'mais %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' mais ',' maison ') where nom_voie like '% mais %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^pist ','piste ') where nom_voie like 'pist %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' pl ',' place ') where nom_voie like '% pl %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'place place ','place ') where nom_voie like 'place place %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' plt ',' plateau ') where nom_voie like '% plt %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )post ','\1poste ') where nom_voie like '%post %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' prom ',' promenade ') where nom_voie like '% prom %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'^ptte ','placette ') where nom_voie like 'ptte %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'pcette ','placette ') where nom_voie like '%pcette %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'placette placette ','placette ') where nom_voie like '%placette placette %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'la pte ','la porte ') where nom_voie like '%la pte %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' pte de ',' porte de ') where nom_voie like '% pte de %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' qua ',' quartier ') where nom_voie like '% qua %';
-- RES
update ban_temp set nom_voie=regexp_replace(nom_voie,' rtd ',' rotonde ') where nom_voie like '% rtd %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' rte ',' route ') where nom_voie like '% rte %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' anc (combat d|combattants|combat$)',' anciens \1') where nom_voie like '%anc comb%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'chemin anc ','chemin ancien ') where nom_voie like '% anc %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'route anc ','route ancienne ') where nom_voie like '% anc %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' anc (voie|porte|tannerie|tanneries)( |$)',' ancienne \1\2') where nom_voie like '% anc %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' rle ',' ruelle ') where nom_voie like '% rle %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' sq ',' square ') where nom_voie like '% sq %';
-- TRA
update ban_temp set nom_voie=regexp_replace(nom_voie,' gde rue ',' grande-rue ') where nom_voie like '% gde %';

-- dédoublonage des désabréviations
update ban_temp set nom_voie=regexp_replace(nom_voie,'(avenue|place|boulevard|placette|ancien|ancienne|petit|petite|voie|voie communale|route|chemin vicinal|lotissement|résidence|ancienne route|chemin|vieux chemin|vieille route|grande.rue|grand.rue) \1','\1') where nom_voie ~ '(avenue|place|boulevard|placette|ancien|ancienne|petit|petite|voie|voie communale|route|chemin vicinal|lotissement|résidence|ancienne route|chemin|vieux chemin|vieille route|grande.rue|grand.rue) \1';
update ban_temp set nom_voie=regexp_replace(nom_voie,'grand.rue (grande.rue)','\1') where nom_voie like '%grande_rue%';

-- nom_voie + nom_ld + alias est vide > reprise du nom d'après noms issus des plans cadastraux (algo BANO)
with u as (select b.id as u_id, f.nom_cadastre from ban_temp b join dgfip_noms_cadastre f on (f.fantoir like b.code_insee||b.id_fantoir||'%') where id_fantoir !='' and nom_voie||nom_ld||alias='' and b.code_insee like '0%' and f.fantoir like '0%') update ban_temp set nom_voie=nom_cadastre from u where id=u_id;
with u as (select b.id as u_id, f.nom_cadastre from ban_temp b join dgfip_noms_cadastre f on (f.fantoir like b.code_insee||b.id_fantoir||'%') where id_fantoir !='' and nom_voie||nom_ld||alias='' and b.code_insee like '1%' and f.fantoir like '1%') update ban_temp set nom_voie=nom_cadastre from u where id=u_id;
with u as (select b.id as u_id, f.nom_cadastre from ban_temp b join dgfip_noms_cadastre f on (f.fantoir like b.code_insee||b.id_fantoir||'%') where id_fantoir !='' and nom_voie||nom_ld||alias='' and b.code_insee like '2%' and f.fantoir like '2%') update ban_temp set nom_voie=nom_cadastre from u where id=u_id;
with u as (select b.id as u_id, f.nom_cadastre from ban_temp b join dgfip_noms_cadastre f on (f.fantoir like b.code_insee||b.id_fantoir||'%') where id_fantoir !='' and nom_voie||nom_ld||alias='' and b.code_insee like '3%' and f.fantoir like '3%') update ban_temp set nom_voie=nom_cadastre from u where id=u_id;
with u as (select b.id as u_id, f.nom_cadastre from ban_temp b join dgfip_noms_cadastre f on (f.fantoir like b.code_insee||b.id_fantoir||'%') where id_fantoir !='' and nom_voie||nom_ld||alias='' and b.code_insee like '4%' and f.fantoir like '4%') update ban_temp set nom_voie=nom_cadastre from u where id=u_id;
with u as (select b.id as u_id, f.nom_cadastre from ban_temp b join dgfip_noms_cadastre f on (f.fantoir like b.code_insee||b.id_fantoir||'%') where id_fantoir !='' and nom_voie||nom_ld||alias='' and b.code_insee like '5%' and f.fantoir like '5%') update ban_temp set nom_voie=nom_cadastre from u where id=u_id;
with u as (select b.id as u_id, f.nom_cadastre from ban_temp b join dgfip_noms_cadastre f on (f.fantoir like b.code_insee||b.id_fantoir||'%') where id_fantoir !='' and nom_voie||nom_ld||alias='' and b.code_insee like '6%' and f.fantoir like '6%') update ban_temp set nom_voie=nom_cadastre from u where id=u_id;
with u as (select b.id as u_id, f.nom_cadastre from ban_temp b join dgfip_noms_cadastre f on (f.fantoir like b.code_insee||b.id_fantoir||'%') where id_fantoir !='' and nom_voie||nom_ld||alias='' and b.code_insee like '7%' and f.fantoir like '7%') update ban_temp set nom_voie=nom_cadastre from u where id=u_id;
with u as (select b.id as u_id, f.nom_cadastre from ban_temp b join dgfip_noms_cadastre f on (f.fantoir like b.code_insee||b.id_fantoir||'%') where id_fantoir !='' and nom_voie||nom_ld||alias='' and b.code_insee like '8%' and f.fantoir like '8%') update ban_temp set nom_voie=nom_cadastre from u where id=u_id;
with u as (select b.id as u_id, f.nom_cadastre from ban_temp b join dgfip_noms_cadastre f on (f.fantoir like b.code_insee||b.id_fantoir||'%') where id_fantoir !='' and nom_voie||nom_ld||alias='' and b.code_insee like '9%' and f.fantoir like '9%') update ban_temp set nom_voie=nom_cadastre from u where id=u_id;


