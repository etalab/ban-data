-- création table temporaire des fichiers en format fixe de La Poste
create table if not exists poste_temp (ligne text);
truncate table poste_temp;

-- création et import table hexaposte de La Poste (correspondance commune/code postal)
drop table if exists poste_hexaposte;
create table poste_hexaposte (id text, insee text, lib_commune text, pluridistrib text, type_cp text, ligne5 text, code_postal text, lib_acheminnement text, insee_ancien text, code_maj text, cea text);
\copy poste_temp from '../data/poste/hsp7aaaa.ai' with (format csv, header true, encoding 'iso8859-1');
insert into poste_hexaposte (select trim(substr(ligne,1,6)), substr(ligne,7,5), trim(substr(ligne,12,38)), substr(ligne,50,1), substr(ligne,51,1), trim(substr(ligne,52,38)),trim(substr(ligne,90,5)),trim(substr(ligne,95,32)),trim(substr(ligne,127,5)),substr(ligne,132,1),trim(substr(ligne,133,10)) from poste_temp);
truncate poste_temp;

-- création et import table hexavia de La Poste (voies et lieux-dits)
drop table if exists poste_hexavia;
create table poste_hexavia (id text, insee text, matricule_voie text, dernier_mot text, lib_voie text, type_voie text, descripteur text, abrege text, scindage text, homonyme text, code_postal text, borne_imp_inf numeric, borne_imp_inf_rpt text, borne_imp_sup numeric, borne_imp_sup_rpt text, borne_pai_inf numeric, borne_pai_inf_rpt text, borne_pai_sup numeric, borne_pai_sup_rpt text, ext_abrege text, roudis text, code_maj text);
\copy poste_temp from '../data/poste/hsv7aaaa.ai' with (format csv, encoding 'iso8859-1', header true);
insert into poste_hexavia (select trim(substr(ligne,2,6)), substr(ligne,8,5), trim(substr(ligne,13,8)), trim(substr(ligne,41,20)), trim(substr(ligne,61,32)), trim(substr(ligne,93,4)),trim(substr(ligne,97,10)),substr(ligne,107,1),substr(ligne,108,1),substr(ligne,109,1),trim(substr(ligne,110,5)),substr(ligne,115,4)::numeric, substr(ligne,119,1),substr(ligne,121,4)::numeric, substr(ligne,125,1),substr(ligne,127,4)::numeric, substr(ligne,131,1),substr(ligne,133,4)::numeric, substr(ligne,137,1), substr(ligne,138,5), substr(ligne,149,1) from poste_temp where ligne like 'V%');
truncate poste_temp;

-- création et import table hexacle de La Poste (points adresse, avec ou sans numéro)
drop table if exists poste_hexacle;
create table poste_hexacle (matricule text, numero text, ext_abrege text, extension text, cea text, code_maj text);
\copy poste_temp from '../data/poste/hsw4aaaa.ai' with (format csv, header true, encoding 'iso8859-1');
insert into poste_hexacle (select trim(substr(ligne,1,8)), trim(substr(ligne,9,4)), substr(ligne,13,1), trim(substr(ligne,14,10)), trim(substr(ligne,24,10)), substr(ligne,25,1) from poste_temp);

drop table poste_temp;

-- création des index
create index hexavia_matricule on poste_hexavia using spgist (matricule_voie) with (fillfactor=100);
create index hexavia_insee on poste_hexavia using spgist (insee);
create index hexaposte_cp on poste_hexaposte using spgist(code_postal);
create index hexaposte_insee on poste_hexaposte using spgist(insee);
create index hexacle_voie on poste_hexacle using spgist(matricule);


