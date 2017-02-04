-- mise à jour de la table des abréviations (regexp)
truncate abrev;
\copy abrev from ../scripts/abrev_regexp.csv with (format csv, header true, force_not_null (option));

-- libellés mis en majuscules non accentuées et alpha-numérique strict
update temp set lib=regexp_replace(regexp_replace(upper(unaccent(lb_voie)),'[^A-Z 0-9]',' ','g'),' +',' ','g');

-- type de voie
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=0 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;

with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=1 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=1 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;

-- titres
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=2 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=2 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=3 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;

with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=4 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=4 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=5 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=5 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=5 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;

with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=9 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=9 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;

-- prénoms
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=10 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=10 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=10 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=10 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;

-- articles
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=14 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=15 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=15 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=15 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=15 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;

with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=20 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=20 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=20 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;
with u as (select lib as u_lib,regexp_replace(lib,avant,apres,option) as new,prio from temp join abrev on (prio=20 and lib ~ avant) where length(lib)>32 group by 1,2,3,avant order by length(regexp_replace(lib,avant,apres,option)) desc) update temp set lib=regexp_replace(new,'  ',' ','g'), p=prio from u where lib=u_lib and length(lib)>32;

update temp set lib=upper(lib);

-- select lib=lib_voie, length(lib)-32, * from temp where p=20 order by 1,2 desc;
select lb_voie,lib_voie,lib from temp where lib!=lib_voie;
