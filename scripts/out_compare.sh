# sort un CSV de comparaison BAN/BANO pour un code INSEE fournit
# ex: ./out_compare.sh 33063 > bordeaux.csv

psql -A -t -c "\copy (with i as (select '$1'::text as insee) select id_fantoir as fantoir_ban, fantoir as fantoir_bano, coalesce(nom_voie, voie) as voie, nb_ban, nb_bano, coalesce(nb_ban,0)-coalesce(nb_bano,0) as diff from (select substring(id,6,4) as fantoir,max(voie) as voie, count(*) as nb_bano, array_agg(num order by num) as num_bano from bano33, i where id like insee||'%' group by 1) as bano full outer join (select id_fantoir, nom_voie, count(*) as nb_ban, array_agg(trim(numero||' '||rep)) as num_ban from ban_temp, i where code_insee=insee and numero::numeric<5000 group by 1,2) as ban on (bano.fantoir=ban.id_fantoir) order by 3) to STDOUT with (format csv, header true)"
