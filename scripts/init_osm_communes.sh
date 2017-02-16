# import des limites administratives issues d'OSM

cd ../data/osm/

# détail communes (2014)
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/communes-plus-20140630-100m-shp.zip
unzip -u -o communes-plus-20140630-100m-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: communes-plus-20140630-100m-shp/communes-plus-20140630-100m.shp -overwrite -nlt GEOMETRY -nln osm_communes -skipfailures
psql -c "
create index osm_communes_index on osm_communes using gist(wkb_geometry);
create index osm_communes_insee on osm_communes (insee);
"

# limites communes au 1/1/2015
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/communes-20150101-5m-shp.zip
unzip -u -o communes-20150101-5m-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: communes-plus-20150101-5m-shp/communes-plus-20150101-5m.shp -overwrite -nlt GEOMETRY -nln osm_communes_2015 -skipfailures
psql -c "
alter table osm_communes_2015 drop ogc_fid;
create index osm_communes_2015_index on osm_communes_2015 using gist(wkb_geometry);
create index osm_communes_2015_insee on osm_communes_2015 (insee);
"

# limites communes au 1/1/2016 pour les fusions
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/communes-20160119-shp.zip
unzip -u -o communes-20160119-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: communes-20160119.shp -overwrite -nlt GEOMETRY -nln osm_communes_2016 -skipfailures
psql -c "
-- nettoyage après import ogr2ogr
alter table osm_communes_2016 drop ogc_fid;
create index osm_communes_2016_insee on osm_communes_2016 (insee);
-- vue pour les fusions 2016
create materialized view fusion2016 as SELECT f.insee,                                                                                                                                         f.nom AS cheflieu,
    co.insee AS insee_delegue,
    co.nom AS nom_delegue,
    2016 AS annee,
    co.wkb_geometry AS geom
   FROM osm_communes_2015 co
     LEFT JOIN osm_communes_2016 cn ON co.insee::text = cn.insee::text AND upper(unaccent(replace(co.nom::text, '-'::text, ' '::text))) = upper(unaccent(replace(cn.nom::text, '-'::text, ' '::text)))
     LEFT JOIN osm_communes_2016 f ON st_intersects(st_centroid(co.wkb_geometry), f.wkb_geometry)
  WHERE cn.insee IS NULL AND (f.insee::text <> ALL (ARRAY['75056'::character varying, '13055'::character varying, '69123'::character varying]::text[]));
-- index sur la vue matérialisée
create index fusion2016_insee on fusion2016 (insee);
create index fusion2016_geom on fusion2016 using gist(geom);
"

# limites communes au 1/1/2017 pour les fusions
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/communes-20170111-shp.zip
unzip -u -o communes-20170111-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: communes-20170112.shp -overwrite -nlt GEOMETRY -nln osm_communes_2017 -skipfailures
psql -c "
-- nettoyage après import ogr2ogr
alter table osm_communes_2017 drop ogc_fid;
create index osm_communes_2017_insee on osm_communes_2017 (insee);
-- vue pour les fusions 2017
create materialized view fusion2017 as  SELECT f.insee,                                                                                                                                        f.nom AS cheflieu,
    co.insee AS insee_delegue,
    co.nom AS nom_delegue,
    2017 AS annee,
    co.wkb_geometry AS geom
   FROM osm_communes_2016 co
     LEFT JOIN osm_communes_2017 cn ON co.insee::text = cn.insee::text AND upper(unaccent(replace(co.nom::text, '-'::text, ' '::text))) = upper(unaccent(replace(cn.nom::text, '-'::text, ' '::text)))
     LEFT JOIN osm_communes_2017 f ON st_intersects(st_centroid(co.wkb_geometry), f.wkb_geometry)
  WHERE cn.insee IS NULL AND (f.insee::text <> ALL (ARRAY['75056'::character varying, '13055'::character varying, '69123'::character varying]::text[]));
-- index sur la vue matérialisée
create index fusion2017_insee on fusion2017 (insee);
create index fusion2017_geom on fusion2017 using gist(geom);
"

# liste des régions 2016 (noms finaux)
wget -nc http://osm13.openstreetmap.fr/~cquest/openfla/export/regions-20170102-shp.zip
unzip regions-20170102-shp.zip
ogr2ogr -t_srs EPSG:4326 -f PostgreSQL PG: regions-20170102.shp -overwrite -nlt GEOMETRY -nln osm_regions_2016 -skipfailures
rm regions-20170102*
psql -c "
create index osm_regions_2016_index on osm_regions_2016 using gist(wkb_geometry);
create index osm_regions_2016_insee on osm_regions_2016 (insee);

create or replace view dep_reg_2016 as select d.*, nom_reg, d2.tncc as dep_tncc, r2.nom as nom_reg2016 from cog_dep d join cog_reg r on (r.reg=d.reg) join insee_depts_2016 d2 on (d2.dep=d.dep) left join osm_regions_2016 r2 on (r2.insee=d2.region);
"
