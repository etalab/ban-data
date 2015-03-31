# traitement de erreurs.csv généré par les scripts check_xxxxx

# import dans postgres
psql -c "drop table if exists errors; create table errors (insee text, id text, col text, val text, info text);"
psql -c "\copy errors from erreurs.csv with (format csv, header false);"

echo "\n-- nombre d'adresse avec anomalie (groupé par département)\n"
psql -c "\copy (select e.dept, nb_adr_err, nb_err, nb_adr, round(100*nb_adr_err/nb_adr,1) as pct_adr_err from (select left(insee,2) as dept, count(*) as nb_err, count(distinct(id)) as nb_adr_err from errors group by 1) as e join (select left(code_insee,2) as dept, count(*) as nb_adr from ban_all group by 1) as a on (e.dept=a.dept) order by 1) to out_check_par_dept.csv with (format csv, header true);"
 
echo "\n-- répartition des types d'anomalies\n"
psql -c "\copy (select regexp_replace(left(info,position(':' in info||':')-1),' [0-9]*( |$)',' ') as type, count(*) as nb_err from errors group by 1 order by 2 desc) to out_check_par_type.csv with (format csv, header true);"

