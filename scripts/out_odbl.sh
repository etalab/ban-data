# export BAN odbl postgres > shapefile, csv, json

OUTDIR=../out/shp

export SHAPE_ENCODING='UTF-8'
ogr2ogr -f "ESRI Shapefile" -lco ENCODING=UTF-8 -s_srs "EPSG:4326" -t_srs "EPSG:4326" -overwrite $OUTDIR/BAN_odbl_$1.shp PG:"dbname=cquest" -sql "SELECT id, nom_voie, id_fantoir, numero, rep, code_insee, code_post, alias, nom_ld, x, y, nom_commune as commune, id_voie as fant_voie, id_ld as fant_ld, st_point(round(lat::numeric,6),round(lon::numeric,6)) from ban_$1 ORDER BY code_insee, fant_voie, fant_ld, nom_voie, nom_ld"

cd $OUTDIR
zip -q -9 BAN_odbl_$1-shp.zip BAN_odbl_$1.* *.txt
cd -

psql -c "\copy (SELECT id, nom_voie, id_fantoir, numero, rep, code_insee, code_post, alias, nom_ld, x, y, nom_commune as commune, id_voie as fant_voie, id_ld as fant_ld, round(lon::numeric,6) as lat, round(lat::numeric,6) as lon FROM ban_$1 ORDER BY code_insee, fant_voie, fant_ld, nom_voie, nom_ld) to '$OUTDIR/BAN_odbl_$1.csv' with (format csv, header true);"

bzip2 -9 $OUTDIR/BAN_odbl_$1.csv -c > $OUTDIR/BAN_odbl_$1-csv.bz2

rm $OUTDIR/BAN_odbl_$1.*

sh out_pg2json.sh $1 | bzip2 -9 -c > $OUTDIR/BAN_odbl_$1-json.bz2

exit

