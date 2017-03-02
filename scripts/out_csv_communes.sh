OUTDIR=../out/odbl/communes/
DBPATH="dbname=ban"
mkdir -p $OUTDIR

for c in `psql -qc "select distinct(code_insee) from ban_$1 order by 1;" -At`
do
  psql -qc "\copy (SELECT id, nom_voie, id_fantoir, numero, rep, code_insee, code_post, alias, nom_ld, x, y, nom_commune as commune, id_voie as fant_voie, id_ld as fant_ld, round(lon::numeric,6) as lat, round(lat::numeric,6) as lon FROM ban_$1 WHERE code_insee='$c' ORDER BY code_insee, fant_voie, fant_ld, nom_voie, nom_ld, numero) to '$OUTDIR/BAN_odbl_$c.csv' with (format csv, header true);"
done
