-- mise à jour de la table des abréviations (regexp)
truncate abrev;
\copy abrev from ../scripts/conf_abrev_0.csv with (format csv, header true);

-- libellés mis en majuscules non accentuées et alpha-numérique strict
update temp set lib=regexp_replace(regexp_replace(upper(unaccent(lb_voie)),'[^A-Z 0-9]',' ','g'),' +',' ','g');

-- type de voie
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=0 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;

with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=1 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=1 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;

-- titres
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=2 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=2 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=3 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;

with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=4 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=4 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=5 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=5 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=5 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=9 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=9 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
-- prénoms
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=10 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=10 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=10 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=10 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
-- articles
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=15 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=15 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=15 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=15 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;

with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=20 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;

with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=20 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;

with u as (select lib as u_lib,avant,apres,option,prio from temp join abrev on (prio=20 and lib ~ avant) where length(lib)>32 group by 1,2,3,4,5 order by length(avant) desc) update temp set lib=replace(regexp_replace(lib,avant,apres,coalesce(option,'')),'  ',' '), p=prio from u where lib=u_lib and length(lib)>32;

select length(lib)-32, * from temp where p=20 order by 1 desc;
