-- script de mise à jour, correction et harmonisation des données

-- code_post: "code_post est vide"
with u as (select id, code_insee, code_post, string_agg(distinct(p.cp),',') as cp, count(distinct(p.cp)) as nb from ban_temp b left join poste_cp c on (c.cp=b.code_post) join poste_cp p on (p.insee=b.code_insee) where c.cp is null group by 1,2,3) update ban_temp b set code_post=u.cp from u where coalesce(b.code_post,'')='' and b.id=u.id and nb=1;

-- nom_ld: suppression des *NOBDUNI*
update ban_temp set nom_ld=replace(nom_ld,'*NOBDUNI*','') where nom_ld like '*NOBDUNI*%';

-- supression nom_ld si déjà contenu dans nom_voie
update ban_temp set nom_ld='' where nom_ld !='' and lower(unaccent(nom_voie))~lower(unaccent(nom_ld)) and nom_ld not like '%(%';

-- nom_voie: "nom_voie contient / avec valeurs repetees"
with u as (select id as u_id,regexp_replace(nom_voie,'^(.*)/\1$','\1') as u_nom from ban_temp where nom_voie ~ '^(.*)/\1$') update ban_temp set nom_voie=u_nom from u where id=u_id;

-- nom_voie=nom1/nom2 + alias vide -> nom_voie=nom1 alias=nom2
with u as (select id as u_id, left(nom_voie, position('/' in nom_voie)-1) as u_nom1, substring(nom_voie, position('/' in nom_voie)+1) as u_nom2 from ban_temp where nom_voie ~ '\/' and NOT nom_voie ~ '\/.*\/' and alias='') update ban_temp set nom_voie=u_nom1, alias=u_nom2 from u where id=u_id and alias='';

-- suppression "lieu-dit xxx" -> "xxx"
update ban_temp set nom_voie=replace(nom_voie,'lieu-dit ',' ') where nom_voie like 'lieu-dit %';

-- abbréviations à conserver (mise en majuscule)
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(tgv|t g v)( |$)','\1TGV\2') where nom_voie like '%tgv%' or nom_voie like '%t g v%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(edf|e d f)( |$)','\1EDF\2') where nom_voie like '%e d f%' or nom_voie like '%edf%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(plm|p l m)( |$)','\1PLM\2') where nom_voie like '%p l m%' or nom_voie like '%plm%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(hlm|h l m)( |$)','\1HLM\2') where nom_voie like '%h l m%' or nom_voie like '%hlm%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(vvf|v v f)( |$)','\1VVF\2') where nom_voie like '%v v f%' or nom_voie like '%vvf%';

-- désabréviation des initiales
update ban_temp set nom_voie=replace(replace(replace(replace(nom_voie,'s c h david','sydney charles houghton davis'),'t p g','trésorier payeur général'),'c e c a',E'communauté européenne du charbon et de l\'acier'),'c g e p','CGEP') where nom_voie ~ ' . . . ';

\! echo "`date +%H:%M:%S` $DEP désabréviations"

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
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )cht ','\1château ') where nom_voie ~ '(^| )cht ';
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
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )mln ','\1moulin ') where nom_voie ~ '(^| )mln ';
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
update ban_temp set nom_voie=regexp_replace(replace(nom_voie,'anc combattant alg',E'des anciens combattants d\'algérie'),' anc (combat d|combattants|combat$)',' anciens \1') where nom_voie like '%anc comb%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'chemin anc ','chemin ancien ') where nom_voie like '% anc %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'route anc ','route ancienne ') where nom_voie like '% anc %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' anc (voie|porte|tannerie|tanneries|route)( |$)',' ancienne \1\2') where nom_voie like '% anc %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' anc (collège|couvent|chem|chemin)( |$)',' ancien \1\2') where nom_voie like '% anc %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' rle ',' ruelle ') where nom_voie like '% rle %';
update ban_temp set nom_voie=regexp_replace(nom_voie,' sq ',' square ') where nom_voie like '% sq %';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )st ','\1saint-') where nom_voie ~ '(^| )st ';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )ste ','\1sainte-') where nom_voie ~ '(^| )ste ';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )stes ','\1saintes-') where nom_voie ~ '(^| )stes ';
update ban_temp set nom_voie=replace(nom_voie,' mqs',' marquis') where nom_voie like '% mqs%'; -- mqs/mqse

-- TRA
update ban_temp set nom_voie=regexp_replace(nom_voie,' gde rue ',' grande-rue ') where nom_voie like '% gde %';

-- dédoublonage des désabréviations
update ban_temp set nom_voie=regexp_replace(nom_voie,'^(.*) \1 ','\1 ') where nom_voie ~ '^(.*) \1 ';
update ban_temp set nom_voie=regexp_replace(nom_voie,'grand.rue (grande.rue)','\1') where nom_voie like '%grande_rue%';

-- nom_voie + nom_ld + alias est vide > reprise du nom d'après noms issus des plans cadastraux (algo BANO)
with u as (select b.id as u_id, f.nom_cadastre from ban_temp b join dgfip_noms_cadastre f on (f.fantoir like '!dep!%' AND f.fantoir like b.code_insee||b.id_fantoir||'%') where id_fantoir !='' and nom_voie||nom_ld||alias='') update ban_temp set nom_voie=nom_cadastre from u where id=u_id;

-- nom_voie vide + nom_ld present + FANTOIR indique LD
update ban_temp set nom_voie=nom_ld, nom_ld='' where nom_voie='' and nom_ld !='' and id_fantoir LIKE 'B%';

-- nom_voie et alias identiques
update ban_temp set alias='' where alias !='' and unaccent(lower(nom_voie))=unaccent(lower(alias));

-- nom_voie contient des double tirets
update ban_temp set nom_voie=replace(nom_voie,'--','-') where nom_voie ~ '--';

-- nom_voie avec tiret/espace (ex: "Chemin Saint- Victor")
update ban_temp set nom_voie=regexp_replace(nom_voie,'([^ ])- ','\1-') where nom_voie ~ '- ';
update ban_temp set nom_voie=regexp_replace(nom_voie,' -([^ ])','-\1') where nom_voie ~ ' -';


\! echo "ré-accentuation"

-- manque d'accentuation
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(allee)( |$)','\1allée\3') where nom_voie like '%allee%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'eglise','église') where nom_voie like '%l_eglise%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(residence)( |$)','\1résidence\3') where nom_voie like '%residence%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(cite)( |$)','\1cité\3') where nom_voie like '%cite%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(emile)( |$)','\1émile\3') where nom_voie like '%emile%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(marechal)( |$)','\1maréchal\3') where nom_voie like '%marechal%';
update ban_temp set nom_voie=regexp_replace(nom_voie,' etienne',' étienne') where nom_voie like '% etienne%';
update ban_temp set nom_voie=regexp_replace(nom_voie,' president',' président') where nom_voie like '% president%';

-- update ban_temp set nom_voie=regexp_replace(nom_voie,'chÂteau','château') where nom_voie like '%chÂteau%';

\! echo "mise en forme nom_voie (capitalisation)"

-- mise en forme nom_voie (capitalisation sauf articles)
update ban_temp set nom_voie=replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(initcap(nom_voie),' Du ',' du '),' De ',' de '),' Le ',' le '),' La ',' la '),' Des ',' des '),' L'||chr(39),' l'||chr(39)),' D'||chr(39),' d'||chr(39)),' Au ',' au '),' Aux ',' aux '),' À ',' à '),' Et ',' et '),' Dit ',' dit '),' Dite ',' dite '),' En ',' en '),' Les ',' les '),' Ou ',' ou ');

-- chiffres romains en majuscule... II III IV VI VII VIII XII XV XIV XXIII
update ban_temp set nom_voie=regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace( regexp_replace(regexp_replace(regexp_replace(regexp_replace(nom_voie,' Ii( |$)',' II\1'), ' Iii( |$)',' III\1'),' Iv( |$)',' IV\1'),' Vi( |$)',' VI\1'),' Vii( |$)',' VII\1'),' Viii( |$)',' VIII\1'),' Xii( |$)',' XII\1'),' Xv( |$)',' XV\1'),' Xiv( |$)',' XIV\1'),' Xxiii( |$)',' XXIII\1') where nom_voie != '' and nom_voie ~ '(^| )[IXV][ixv]*( |$)';

-- erreurs d'accentuation
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(du Fosse)( |$)','\1du Fossé\3') where nom_voie like '%du Fosse%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(Eglise)( |$)','\1Église\3') where nom_voie like '%Eglise%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(Gabriel Peri)( |$)','\1Gabriel Péri\3') where nom_voie like '%Gabriel Peri%';
-- update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(Abbe)( |$)','\1Abbé\3') where nom_voie like '%Abbe%';
-- update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(Ampere)( |$)','\1Ampère\3') where nom_voie like '%Ampere%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(Benoit)( |$)','\1Benoît\3') where nom_voie like '%Benoit%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(Chenes)( |$)','\1Chênes\3') where nom_voie like '%Chenes%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(Chene)( |$)','\1Chêne\3') where nom_voie like '%Chene%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(Franche.Comte)( |$)','\1Franche-Comté\3') where nom_voie like '%Franche_Comte%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(Francois)( |$)','\1François\3') where nom_voie like '%Francois%';
update ban_temp set nom_voie=regexp_replace(nom_voie,'(^| )(Clémenceau)( |$)','\1Clemenceau\3') where nom_voie like '%Clémenceau%';

-- Saint et Sainte avec tiret
update ban_temp set nom_voie=replace(nom_voie,'Saint ','Saint-') where nom_voie ~ 'Saint ';
update ban_temp set nom_voie=replace(nom_voie,'Sainte ','Sainte-') where nom_voie ~ 'Sainte ';

-- L et D apostrophe...
update ban_temp set nom_voie=replace(nom_voie,' D ',' d'||chr(39)) where nom_voie ~ ' D [^0-9]';
update ban_temp set nom_voie=replace(nom_voie,' L ',' l'||chr(39)) where nom_voie ~ ' L ';

-- nom_ld et alias identiques
update ban_temp set nom_ld=alias, alias='' where nom_ld !='' and replace(lower(unaccent(nom_ld)),'-',' ')=replace(lower(unaccent(alias)),'-',' ');

-- nom_voie et nom_ld identiques
update ban_temp set nom_ld='' where nom_ld !='' and unaccent(lower(nom_voie))=unaccent(lower(nom_ld));

-- nom_ld et nom_commune identiques (avant désabréviation de nom_ld)
update ban_temp set nom_ld='' where nom_ld !='' and replace(replace(unaccent(lower(nom_commune)),'-',' '),chr(39),' ')=replace(replace(lower(nom_ld),'-',' '),chr(39),' ');

\! echo "id_ld depuis nom_ld"

-- mise à jour id_fantoir par rapprochement avec nom_ld
with u as (select b.code_insee as u_insee, nom_ld as u_nom, string_agg(distinct(f.id_voie),',') as u_code, count(distinct(f.id_voie)) as u_nb from ban_temp b left join dgfip_fantoir f on (b.code_insee=f.code_insee and f.date_annul='0000000' and nom_ld=replace(replace(replace(replace(trim(f.nature_voie||' '||f.libelle_voie),chr(39),' '),'-',' '),'.',' '),'  ',' ')) where nom_voie='' and nom_ld!='' and id_fantoir='' group by 1,2) update ban_temp set id_fantoir=u_code from u where code_insee=u_insee and nom_ld=u_nom and u_nb=1 and u_code ~ '^[ABX]';
with u as (select b.code_insee as u_insee, nom_ld as u_nom, string_agg(distinct(f.id_voie),',') as u_code, count(distinct(f.id_voie)) as u_nb from ban_temp b left join dgfip_fantoir f on (b.code_insee=f.code_insee and nom_ld=replace(replace(replace(replace(trim(f.nature_voie||' '||f.libelle_voie),chr(39),' '),'-',' '),'.',' '),'  ',' ')) where nom_voie='' and nom_ld!='' and id_fantoir='' group by 1,2) update ban_temp set id_fantoir=u_code from u where code_insee=u_insee and nom_ld=u_nom and u_nb=1 and u_code ~ '^[ABX]';

\! echo "désabréviation nom_ld"

-- nom_ld avec premier mot doublé (avant désabréviation)
update ban_temp set nom_ld=regexp_replace(nom_ld,'^([A-Z]*) \1( |$)','\1\2') where nom_ld!='' and nom_ld ~ '^([A-Z]*) \1( |$)';

-- désabreviation de nom_ld
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )CH ','\1CHEMIN ') where nom_ld ~ '(^| )CH ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^CHL( |$)','CHALET\1') where nom_ld ~ '^CHL( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^COR( |$)','CORNICHE\1') where nom_ld ~ '^COR( |$)' and not nom_ld ~ 'COR DE CHASSE';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )CHP( |$)','\1CHAMP\2') where nom_ld ~ '(^| )CHP( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )CHT( |$)','\1CHATEAU\2') where nom_ld ~ '(^| )CHT( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )H L M( |$)','\1HLM\2') where nom_ld ~ '(^| )H L M( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^LOT( |$)','LOTISSEMENT\1') where nom_ld ~ '^LOT( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^RES( |$)','RESIDENCE\1') where nom_ld ~ '^RES( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^HAM( |$)','HAMEAU\1') where nom_ld ~ '^HAM( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^VGE( |$)','VILLAGE\1') where nom_ld ~ '^VGE( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^DOM( |$)','DOMAINE\1') where nom_ld ~ '^DOM( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^DRA( |$)','DRAILLE\1') where nom_ld ~ '^DRA( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )VLA( |$)','\1VILLA\2') where nom_ld ~ '(^| )VLA( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )MLN( |$)','\1MOULIN\2') where nom_ld ~ '(^| )MLN( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )FRM( |$)','\1FERME\2') where nom_ld ~ '(^| )FRM( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )BRG( |$)','\1BOURG\2') where nom_ld ~ '(^| )BRG( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^IMM( |$)','IMMEUBLE\1') where nom_ld ~ '^IMMEUBLE( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^CCAL( |$)','CENTRE COMMERCIAL\1') where nom_ld ~ '^CCAL( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^PTE( |$)','PORTE\1') where nom_ld ~ '^PTE( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^ETNG( |$)','ETANG\1') where nom_ld ~ '^ETNG( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^(LDT|LD) ','') where nom_ld ~ '^(LDT|LD) ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^PKG( |$)','PARKING\1') where nom_ld ~ '^PKG( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )ST[ -] ','\1SAINT-') where nom_ld ~ '(^| )ST[ -]';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )STE[ -] ','\1SAINTE-') where nom_ld ~ '(^| )STE[ -]';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )TUN( |$)','\1TUNNEL\2') where nom_ld ~ '(^| )TUN( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )GDE ','\1GRANDE ') where nom_ld ~ '(^| )GDE ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )GD ','\1GRAND ') where nom_ld ~ '(^| )GD ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^GPE ','GROUPE ') where nom_ld ~ '^GPE ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^CTR ','CENTRE ') where nom_ld ~ '^CTR ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^DEVI( |$)','DEVIATION\1') where nom_ld ~ '^DEVI( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^ECL( |$)','ECLUSE\1') where nom_ld ~ '^ECL( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^ZONE ARTISANAL ','ZONE ARTISANALE ') where nom_ld ~ '^ZONE ';
update ban_temp set nom_ld=regexp_replace(nom_ld,' SAINT ',' SAINT-') where nom_ld ~ ' SAINT ';
update ban_temp set nom_ld=regexp_replace(nom_ld,' SAINTE ',' SAINTE-') where nom_ld ~ ' SAINTE ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^CC( |$)','CHEMIN COMMUNAL\1') where nom_ld ~ '^CC( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^CPG( |$)','CAMPING\1') where nom_ld ~ '^CPG( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^CPGNE( |$)','CAMPAGNE\1') where nom_ld ~ '^CPGNE( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^(BSTD|BAST)( |$)','BASTIDE\2') where nom_ld ~ '^(BSTD|BAST)( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^DARS( |$)','DARSE\1') where nom_ld ~ '^DARS( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^FOYR( |$)','FOYER\1') where nom_ld ~ '^FOYR( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^PLAG( |$)','PLAGE\1') where nom_ld ~ '^PLAG( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^TRN( |$)','TERRAIN\1') where nom_ld ~ '^TRN( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'DSU ','DESSUS ') where nom_ld ~ 'DSU ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'DSO ','DESSOUS ') where nom_ld ~ 'DSO ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'^ABE  ','ABBAYE ') where nom_ld ~ '^ABE ';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )HLG( |$)','\1HALAGE\2') where nom_ld ~ '(^| )HLG( |$)';
update ban_temp set nom_ld=regexp_replace(nom_ld,'(^| )JCT( |$)','\1JONCTION\2') where nom_ld ~ '(^| )JCT( |$)';

-- non traités: BSN CLOI PN PLN AMI CGNE COLI PLT FON MAN ZAV ENC PNT GARN MF HIP CHL GRI PAL BRE BRD PCE GCH (grand chemin) DFL LCF DCR DIM RTM PRL PRQ BCP (bataillon chasseurs alpins) BTN (bataillon) RTF CHS FTP (francs-tireurs partisans) CBR STR MQS (marquis) PPF

\! echo "apostrophe manquante"

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

-- mise à jour code fantoir manquant d'après nom_ld identique
with u as (select b.*, f2.id_voie from (select b.code_insee, nom_ld from ban_temp b where id_fantoir='' and nom_voie='' and nom_ld !='' group by 1,2) as b join dgfip_fantoir f2 on (f2.code_insee=b.code_insee and replace(replace(b.nom_ld,'-',' '),chr(39),' ') = replace(replace(trim(f2.nature_voie||' '||f2.libelle_voie),'-',' '),chr(39),' ') and f2.date_annul='0000000')) update ban_temp b set id_fantoir=u.id_voie from u where b.code_insee=u.code_insee and b.id_fantoir='' and b.nom_ld=u.nom_ld;

\! echo "geometrie"

-- ajout colonne géométrie
alter table BAN_TEMP add geom geometry;
update BAN_TEMP set geom = st_setsrid(st_makepoint(lat,lon),4326);

\! echo "fusion 2016/2017"

-- recherche des codes INSEE dans communes déléguées (via intersection géométrique)
alter table BAN_TEMP add insee_2016 text; -- tableau des anciens codes INSEE
update BAN_TEMP b set insee_2016 = f.insee from  fusion2017 f where ST_contains(f.geom, b.geom);
alter table BAN_TEMP add insee_2015 text; -- tableau des anciens codes INSEE
update BAN_TEMP b set insee_2015 = f.insee from  fusion2016 f where ST_contains(f.geom, b.geom);

\! echo "nom fusions"

-- ajout colonne anciens noms de commune et anciens code insee
alter table BAN_TEMP add nom_fusion text;

-- on élimine les anciens noms identiques dans nom_voie et nom_ld
with u as (select id as u_id, trim(regexp_replace(nom_ld,'\(.*','')) as ld from ban_temp where nom_voie like '%(%' and nom_ld like '%(%' and upper(unaccent(regexp_replace(nom_voie,'^.*\(','(')))=upper(unaccent(regexp_replace(nom_ld,'^.*\(','(')))) update ban_temp set nom_ld=ld from u where id=u_id;
-- on sépare les anciens noms entre parenthèse de nom_voie
update BAN_TEMP set nom_fusion = regexp_replace(nom_voie, '^.*\((.*)\)','\1') where nom_voie ~ '\(';
update BAN_TEMP set nom_voie = trim(regexp_replace(nom_voie,'\(.*','')) where nom_voie ~ '\(';
-- on sépare les anciens noms entre parenthèse du nom_ld
update BAN_TEMP set nom_ld = trim(regexp_replace(nom_ld,'\(.*','')) where nom_ld ~ '\(';
-- on complète nom_fusion avec le nom de l'ancienne commune si il n'est pas déjà présent
with u as (select id as u_id, coalesce(nom_fusion||', ','')||nom_delegue as nom_2016 from BAN_TEMP b join fusion2016 f on (f.insee=b.code_insee and ST_Contains(f.geom, b.geom) and replace(upper(unaccent(coalesce(b.nom_fusion,''))),'-',' ') !~ replace(upper(unaccent(f.nom_delegue)),'-',' '))) update BAN_TEMP set nom_fusion=nom_2016 from u where id=u_id;
-- pareil pour les fusions de 2017
with u as (select id as u_id, coalesce(nom_fusion||', ','')||nom_delegue as nom_2017 from BAN_TEMP b join fusion2017 f on (f.insee=b.code_insee and ST_Contains(f.geom, b.geom) and replace(upper(unaccent(coalesce(b.nom_fusion,''))),'-',' ') !~ replace(upper(unaccent(f.nom_delegue)),'-',' '))) update BAN_TEMP set nom_fusion=nom_2017 from u where id=u_id;

\! echo "nettoyage/harmonisation des anciens noms de communes"

-- nettoyage/harmonisation des anciens noms de communes
with u as (select nom_fusion as u_fusion, regexp_replace(nom_fusion, reg, '\1'||nom_delegue||'\2','gi') as u_clean from (select nom_fusion from BAN_TEMP where nom_fusion is not null group by 1) b join (select nom_delegue, '(^| )'||regexp_replace(upper(unaccent(nom_delegue)),'[^A-Z]','.','g')||'(,|$)' as reg from fusion2017) as n on (upper(unaccent(nom_fusion))~reg) where nom_fusion is not null) update BAN_TEMP set nom_fusion = trim(u_clean) from u where nom_fusion=u_fusion;

with u as (select nom_fusion as u_fusion, regexp_replace(nom_fusion, reg, '\1'||nom_delegue||'\2','gi') as u_clean from (select nom_fusion from BAN_TEMP where nom_fusion is not null group by 1) b join (select nom_delegue, '(^| )'||regexp_replace(upper(unaccent(nom_delegue)),'[^A-Z]','.','g')||'(,|$)' as reg from fusion2016) as n on (upper(unaccent(nom_fusion))~reg) where nom_fusion is not null) update BAN_TEMP set nom_fusion = trim(u_clean) from u where nom_fusion=u_fusion;


\! echo "codes FANTOIR"

-- recherche du code FANTOIR correspondant à la voie et stockage dans id_voie
with u as (select b.code_insee as u_insee, nom_voie as u_nom, f.fantoir from ban_temp b left join libelles_join l1 on (l1.long=upper(unaccent(nom_voie))) left join dgfip_fantoir f on (f.lib_court=l1.long and f.code_insee=b.code_insee)  where b.id_voie is null and nom_voie != '' group by 1,2,3) update ban_temp SET id_voie = fantoir from u where code_insee=u_insee and nom_voie=u_nom and fantoir is not null;

-- recherche du code FANTOIR correspondant au lieu-dit et stockage dans id_ld
with u as (select b.code_insee as u_insee, nom_ld as u_nom, f.fantoir from ban_temp b left join libelles_join l1 on (l1.long=upper(unaccent(nom_ld))) left join dgfip_fantoir f on (f.lib_court=l1.long and f.code_insee=b.code_insee) where b.id_ld is null and nom_ld != '' group by 1,2,3) update ban_temp SET id_ld = fantoir from u where code_insee=u_insee and nom_ld=u_nom and fantoir is not null;

-- recherche du code FANTOIR correspondant à la voie et stockage dans id_voie (communes fusionnées en 2017)
WITH u as (SELECT b.id as u_id, f.fantoir FROM (select unnest(ids) as id, upper(unaccent(nom_voie)) as nom from ban_temp b join fusion2017 f on (f.insee=b.code_insee) where id_voie is null and nom_voie !='' group by 1,2) as l left join libelles_join lc on (lc.long=l.nom) JOIN BAN_TEMP b ON (b.id=l.id and b.id_voie is null and b.nom_voie!='') left join dgfip_fantoir f on (f.lib_court=lc.long2 and f.code_insee=b.insee_2016) GROUP BY 1,2) UPDATE BAN_TEMP SET id_voie=fantoir FROM u WHERE id=u_id and id_voie is null and fantoir is not null;

-- recherche du code FANTOIR correspondant à la voie et stockage dans id_voie (communes fusionnées en 2016)
WITH u as (SELECT b.id as u_id, f.fantoir FROM (select unnest(ids) as id, upper(unaccent(nom_voie)) as nom from ban_temp b join fusion2016 f on (f.insee=b.code_insee) where id_voie is null and nom_voie !='' group by 1,2) as l left join libelles_join lc on (lc.long=l.nom) JOIN BAN_TEMP b ON (b.id=l.id and b.id_voie is null and b.nom_voie!='') left join dgfip_fantoir f on (f.lib_court=lc.long2 and f.code_insee=b.insee_2015) GROUP BY 1,2) UPDATE BAN_TEMP SET id_voie=fantoir FROM u WHERE id=u_id and id_voie is null and fantoir is not null;

-- recherche du code FANTOIR correspondant au lieu-dit et stockage dans id_ld (communes fusionnées en 2017)
WITH u as (SELECT b.id as u_id, f.fantoir FROM (select unnest(ids) as id, upper(unaccent(nom_ld)) as nom from ban_temp b join fusion2017 f on (f.insee=b.code_insee) where id_ld is null and nom_ld !='' group by 1,2) as l left join libelles_join lc on (lc.long=l.nom) JOIN BAN_TEMP b ON (b.id=l.id and b.id_ld is null) left join dgfip_fantoir f on (f.lib_court=lc.long2 and f.code_insee=b.insee_2016) GROUP BY 1,2) UPDATE BAN_TEMP SET id_ld=fantoir FROM u WHERE id=u_id and fantoir is not null;

-- recherche du code FANTOIR correspondant au lieu-dit et stockage dans id_ld (communes fusionnées en 2016)
WITH u as (SELECT b.id as u_id, f.fantoir FROM (select unnest(ids) as id, upper(unaccent(nom_ld)) as nom from ban_temp b join fusion2016 f on (f.insee=b.code_insee) where id_ld is null and nom_ld !='' group by 1,2) as l left join libelles_join lc on (lc.long=l.nom) JOIN BAN_TEMP b ON (b.id=l.id and b.id_ld is null) left join dgfip_fantoir f on (f.lib_court=lc.long2 and f.code_insee=b.insee_2015) GROUP BY 1,2) UPDATE BAN_TEMP SET id_ld=fantoir FROM u WHERE id=u_id and fantoir is not null;


-- on reporte les noms remis en forme et les id FANTOIR sur les adresses
with u as (select unnest(ids) as adr_id, nom_voie as u_nom_voie, nom_ld as u_nom_ld, alias as u_alias, id_voie as u_id_voie, id_ld as u_id_ld from ban_temp) update BAN_TEMP set nom_voie=u_nom_voie,nom_ld=u_nom_ld,alias=u_alias,id_voie=u_id_voie,id_ld=u_id_ld from u where id=adr_id;
