# import des limites administratives issues d'OSM

cd ../data/osm/
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/communes-plus-20140630-100m-shp.zip
unzip -o communes-plus-20140630-100m-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: communes-plus-20140630-100m-shp/communes-plus-20140630-100m.shp -overwrite -nlt GEOMETRY -nln osm_communes -skipfailures
psql -c "
create index osm_communes_index on osm_communes using gist(wkb_geometry);
create index osm_communes_insee on osm_communes (insee);
"

wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/communes-20150101-5m-shp.zip
unzip -o communes-20150101-5m-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: communes-plus-20150101-5m-shp/communes-plus-20150101-5m.shp -overwrite -nlt GEOMETRY -nln osm_communes_2015 -skipfailures
psql -c "
create index osm_communes_2015_index on osm_communes_2015 using gist(wkb_geometry);
create index osm_communes_2015_insee on osm_communes_2015 (insee);
"


# liste des régions 2016 (noms finaux)
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/regions-20170102-shp.zip
unzip regions-20170102-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: regions-20170102.shp -overwrite -nlt GEOMETRY -nln osm_regions_2016 -skipfailures
rm regions-20170102*
psql -c "
create index osm_regions_2016_index on osm_regions_2016 using gist(wkb_geometry);
create index osm_regions_2016_insee on osm_regions_2016 (insee);
"
