-- script de mise à jour, correction et harmonisation des données

-- code_post: "code_post est vide"
with u as (select id, code_insee, code_post, string_agg(distinct(p.cp),',') as cp, count(distinct(p.cp)) as nb from ban_temp b left join poste_cp c on (c.cp=b.code_post) join poste_cp p on (p.insee=b.code_insee) where c.cp is null group by 1,2,3) update ban_temp b set code_post=u.cp from u where b.id=u.id and nb=1;

-- nom_ld: suppression des *NOBDUNI*
update ban_temp set nom_ld=replace(nom_ld,'*NOBDUNI*','') where nom_ld like '*NOBDUNI*%';

-- supression nom_ld si déjà contenu dans nom_voie
update ban_temp set nom_ld='' where nom_ld !='' and lower(unaccent(nom_voie))~lower(unaccent(nom_ld));

-- nom_voie: "nom_voie contient / avec valeurs repetees"
with u as (select id as u_id,regexp_replace(nom_voie,'^(.*)/\1$','\1') as u_nom from ban_temp where nom_voie ~ '^(.*)/\1$') update ban_temp set nom_voie=u_nom from u where id=u_id;

-- nom_voie=nom1/nom2 + alias vide -> nom_voie=nom1 alias=nom2
with u as (select id as u_id, left(nom_voie, position('/' in nom_voie)-1) as u_nom1, substring(nom_voie, position('/' in nom_voie)+1) as u_nom2 from ban_temp where nom_voie ~ '\/' and NOT nom_voie ~ '\/.*\/' and alias='') update ban_temp set nom_voie=u_nom1, alias=u_nom2 from u where id=u_id and alias='';

-- désabréviations...
update ban_temp set nom_voie=regexp_replace(nom_voie,'^aer ','aérodrome ') where nom_voie like 'aer %';
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
update ban_temp set nom_voie=regexp_replace(nom_voie,' mal (de |leclerc|delat)',' maréchal \1') where nom_voie like '% mal %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' reg ',' régiment ') where nom_voie like '% reg %';
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
with u as (select b.id as u_id, f.nom_cadastre from ban_temp b join dgfip_noms_cadastre f on (f.fantoir like b.code_insee||b.id_fantoir||'%') where id_fantoir !='' and nom_voie||nom_ld||alias='') update ban_temp set nom_voie=nom_cadastre from u where id=u_id;

-- nom_voie vide + nom_ld present + FANTOIR indique LD
update ban_temp set nom_voie=nom_ld, nom_ld='' where nom_voie='' and nom_ld !='' and id_fantoir LIKE 'B%';

-- nom_voie et alias identiques
update ban_temp set alias='' where alias !='' and unaccent(lower(nom_voie))=unaccent(lower(alias));

-- nom_voie contient des double tirets
update ban_temp set nom_voie=replace(nom_voie,'--','-') where nom_voie like '%--%';

-- nom_voie avec tiret/espace (ex: "Chemin Saint- Victor")
update ban_temp set nom_voie=regexp_replace(nom_voie,'([^ ])- ','\1-') where nom_voie like '%- %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' -([^ ])','-\1') where nom_voie like '% -%';

-- calcul nom_temp, version abbrégée de nom_voie pour rapprochement FANTOIR
alter table ban_temp add nom_temp text;
update ban_temp set nom_temp=regexp_replace(replace(replace(upper(unaccent(nom_voie)),'-',' '),chr(39),' '),' *',' ') where id_fantoir='' and nom_voie!='';
with u as (select * from abbrev where txt_long != txt_court ORDER BY length(txt_long) DESC) update ban_temp set nom_temp=regexp_replace(nom_temp,'(^| )'||txt_long||'( |$)','\1'||txt_court||'\2') from u where nom_temp LIKE '%'||txt_long||'%' ;

-- test de rapprochement
-- select b.code_insee, nom_voie, nom_temp, string_agg(distinct(f.id_voie),',') as code, count(distinct(f.id_voie)) as nb, string_agg(distinct(m.id_voie),',') as mot, string_agg(distinct(m.nature_voie||' '||m.libelle_voie),',') from ban_temp b left join dgfip_fantoir f on (b.code_insee=f.code_insee and nom_temp=replace(replace(replace(replace(trim(f.nature_voie||' '||f.libelle_voie),chr(39),' '),'-',' '),'.',' '),'  ',' ')) left join dgfip_fantoir m on (b.code_insee=m.code_insee and nom_temp LIKE '% '||m.dernier_mot) where nom_temp is not null and id_fantoir='' and b.code_insee like '0%' group by 1,2,3;

-- mise à jour id_fantoir à partir de nom_temp, version abbrégée de nom_voie
with u as (select b.code_insee as u_insee, nom_temp as u_nom, string_agg(distinct(f.id_voie),',') as u_code, count(distinct(f.id_voie)) as u_nb from ban_temp b left join dgfip_fantoir f on (b.code_insee=f.code_insee and f.date_annul='0000000' and nom_temp=replace(replace(replace(replace(trim(f.nature_voie||' '||f.libelle_voie),chr(39),' '),'-',' '),'.',' '),'  ',' ')) where nom_temp is not null and id_fantoir='' group by 1,2) update ban_temp set id_fantoir=u_code, nom_temp = null from u where code_insee=u_insee and nom_temp=u_nom and u_nb=1;

-- test de rapprochement
-- select b.code_insee, nom_ld, nom_temp, string_agg(distinct(f.id_voie),',') as code, count(distinct(f.id_voie)) as nb, string_agg(distinct(m.id_voie),',') as mot, string_agg(distinct(m.nature_voie||' '||m.libelle_voie),',') from ban_temp b left join dgfip_fantoir f on (b.code_insee=f.code_insee and nom_ld=replace(replace(replace(replace(trim(f.nature_voie||' '||f.libelle_voie),chr(39),' '),'-',' '),'.',' '),'  ',' ')) left join dgfip_fantoir m on (b.code_insee=m.code_insee and nom_ld LIKE '% '||m.dernier_mot) where nom_voie='' and nom_ld!='' and id_fantoir='' and b.code_insee like '0%' group by 1,2,3 order by code ;

-- mise à jour id_fantoir par rapprochement avec nom_ld
with u as (select b.code_insee as u_insee, nom_ld as u_nom, string_agg(distinct(f.id_voie),',') as u_code, count(distinct(f.id_voie)) as u_nb from ban_temp b left join dgfip_fantoir f on (b.code_insee=f.code_insee and f.date_annul='0000000' and nom_ld=replace(replace(replace(replace(trim(f.nature_voie||' '||f.libelle_voie),chr(39),' '),'-',' '),'.',' '),'  ',' ')) where nom_voie='' and nom_ld!='' and id_fantoir='' group by 1,2) update ban_temp set id_fantoir=u_code from u where code_insee=u_insee and nom_ld=u_nom and u_nb=1 and u_code ~ '^[ABX]';
with u as (select b.code_insee as u_insee, nom_ld as u_nom, string_agg(distinct(f.id_voie),',') as u_code, count(distinct(f.id_voie)) as u_nb from ban_temp b left join dgfip_fantoir f on (b.code_insee=f.code_insee and nom_ld=replace(replace(replace(replace(trim(f.nature_voie||' '||f.libelle_voie),chr(39),' '),'-',' '),'.',' '),'  ',' ')) where nom_voie='' and nom_ld!='' and id_fantoir='' group by 1,2) update ban_temp set id_fantoir=u_code from u where code_insee=u_insee and nom_ld=u_nom and u_nb=1 and u_code ~ '^[ABX]';

-- mise en forme nom_voie (capitalisation sauf articles)
update ban_temp set nom_voie=replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(initcap(nom_voie),' Du ',' du '),' De ',' de '),' Le ',' le '),' La ',' la '),' Des ',' des '),' L'||chr(39),' l'||chr(39)),' D'||chr(39),' d'||chr(39)),' Au ',' au '),' Aux ',' aux '),' À ',' à '),' Et ',' et '),' Dit ',' dit '),' Dite ',' dite '),' En ',' en '),' Les ',' les '),' Ou ',' ou ');

-- chiffres romains en majuscule... II III IV VI VII VIII XII XV XIV XXIII
update ban_temp set nom_voie=regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace( regexp_replace(regexp_replace(regexp_replace(regexp_replace(nom_voie,' Ii( |$)',' II\1'), ' Iii( |$)',' III\1'),' Iv( |$)',' IV\1'),' Vi( |$)',' VI\1'),' Vii( |$)',' VII\1'),' Viii( |$)',' VIII\1'),' Xii( |$)',' XII\1'),' Xv( |$)',' XV\1'),' Xiv( |$)',' XIV\1'),' Xxiii( |$)',' XXIII\1') where nom_voie != '' and nom_voie ~ '(^| )[IXV][ixv]*( |$)';

-- Saint et Sainte avec tiret
update ban_temp set nom_voie=replace(nom_voie,'Saint ','Saint-') where nom_voie ~ 'Saint ';
update ban_temp set nom_voie=replace(nom_voie,'Sainte ','Sainte-') where nom_voie ~ 'Sainte ';

-- L et D apostrophe...
update ban_temp set nom_voie=replace(nom_voie,' D ',' d'||chr(39)) where nom_voie ~ ' D ';
update ban_temp set nom_voie=replace(nom_voie,' L ',' l'||chr(39)) where nom_voie ~ ' L ';

-- nom_ld et alias identiques
update ban_temp set nom_ld=alias, alias='' where nom_ld !='' and replace(lower(unaccent(nom_ld)),'-',' ')=replace(lower(unaccent(alias)),'-',' ');

-- nom_voie et nom_ld identiques
update ban_temp set nom_ld='' where nom_ld !='' and unaccent(lower(nom_voie))=unaccent(lower(nom_ld));

-- nom_ld et nom_commune identiques (avant désabréviation de nom_ld)
update ban_temp set nom_ld='' where nom_ld !='' and replace(replace(unaccent(lower(nom_commune)),'-',' '),chr(39),' ')=replace(replace(lower(nom_ld),'-',' '),chr(39),' ');

-- nom_ld avec premier mot doublé (avant désabréviation)
update ban_temp set nom_ld=regexp_replace(nom_ld,'^([A-Z]*) \1( |$)','\1\2') where nom_ld!='' and nom_ld ~ '^([A-Z]*) \1( |$)';

-- désabreviation de nom_ld
update ban_temp set nom_ld=regexp_replace(nom_ld,'^LOT ','LOTISSEMENT ') where nom_ld ~ '^LOT ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^RES ','RESIDENCE ') where nom_ld ~ '^RES ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^HAM ','HAMEAU ') where nom_ld ~ '^HAM ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^VGE ','VILLAGE ') where nom_ld ~ '^VGE ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^DOM ','DOMAINE ') where nom_ld ~ '^DOM ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^VLA ','VILLA ') where nom_ld ~ '^VLA ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^MLN ','MOULIN ') where nom_ld ~ '^MLN ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^CHT ','CHATEAU ') where nom_ld ~ '^CHT ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^FRM ','FERME ') where nom_ld ~ '^FRM ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^BRG ','BOURG ') where nom_ld ~ '^BRG ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^IMM ','IMMEUBLE ') where nom_ld ~ '^IMMEUBLE ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^CCAL ','CENTRE COMMERCIAL ') where nom_ld ~ '^CCAL ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^PTE ','PORTE ') where nom_ld ~ '^PTE ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^ETNG ','ETANG ') where nom_ld ~ '^ETNG ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^LDT ','') where nom_ld ~ '^LDT ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^PKG ','PARKING ') where nom_ld ~ '^PKG ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^ST[ -] ','SAINT-') where nom_ld ~ '^ST[ -]';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^STE[ -] ','SAINTE-') where nom_ld ~ '^STE[ -]';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^TUN ','TUNNEL ') where nom_ld ~ '^TUN ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^GDE ','GRANDE ') where nom_ld ~ '^GDE ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^GD ','GRAND ') where nom_ld ~ '^GD ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^GPE ','GROUPE ') where nom_ld ~ '^GPE ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^CTR ','CENTRE ') where nom_ld ~ '^CENTRE ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^DEVI ','DEVIATION ') where nom_ld ~ '^DEVIATION ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^ECL ','ECLUSE ') where nom_ld ~ '^ECL ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^ZONE ARTISANAL ','ZONE ARTISANALE ') where nom_ld ~ '^ZONE ';
update ban_temp set nom_ld=regexp_replace(nom_ld,' SAINT ',' SAINT-') where nom_ld ~ ' SAINT ';
update ban_temp set nom_ld=regexp_replace(nom_ld,' SAINTE ',' SAINTE-') where nom_ld ~ ' SAINTE ';

-- apostrophes manquantes
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )(D|L|QU|PRESQU) ([AEIOUYH])','\1\2'||chr(39)||'\3','g') where nom_ld ~ '(^| )(D|L|QU|PRESQU) [AEIOUYH]';

-- nom_ld et alias identiques (après désabréviation de nom_ld)
update ban_temp set nom_ld=alias, alias='' where nom_ld !='' and replace(lower(unaccent(nom_ld)),'-',' ')=replace(lower(unaccent(alias)),'-',' ');

-- nom_voie et nom_ld identiques (après désabréviation de nom_ld)
update ban_temp set nom_ld='' where nom_ld !='' and unaccent(lower(nom_voie))=unaccent(lower(nom_ld));

-- nom_ld et nom_commune identiques (après désabréviation de nom_ld)
update ban_temp set nom_ld='' where nom_ld !='' and replace(replace(unaccent(lower(nom_commune)),'-',' '),chr(39),' ')=replace(replace(lower(nom_ld),'-',' '),chr(39),' ');

-- nom_ld avec premier mot doublé (après désabréviation)
update ban_temp set nom_ld=regexp_replace(nom_ld,'^([A-Z]*) \1( |$)','\1\2') where nom_ld!='' and nom_ld ~ '^([A-Z]*) \1( |$)';
