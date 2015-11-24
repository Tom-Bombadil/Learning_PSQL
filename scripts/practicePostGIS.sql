createdb practicePG

psql practicePG

CREATE EXTENSION postgis;
SELECT postgis_full_version();


-- SRID_Albers = 5070


CREATE DATABASE practicePG WITH TEMPLATE sheds_new OWNER jeff;

createdb practicePG WITH TEMPLATE sheds_new OWNER jeff;

createdb practicePG -T sheds_new OWNER jeff;


-- psql -U postgres -d <DBNAME> -c "SELECT postgis_version()"

psql -U kyle -d practicePG -c "SELECT postgis_version()"


psql "SELECT postgis_version()"


-- shp2pgsql -I -s <SRID> <PATH/TO/SHAPEFILE> <SCHEMA>.<DBTABLE> | psql -U postgres -d <DBNAME>
shp2pgsql -I -s 5070 /home/kyle/practice/postGIS/shapefiles/catsWB.shp catchments | psql -U kyle -d practicePG

shp2pgsql -s 4326:4326 -g geom -I -c -t 2D $FILE_WGS $TABLE | psql -d $DB -q
shp2pgsql -s 4326:4326 -g geom -I -c -t 2D /home/kyle/practice/postGIS/shapefiles/catsWB.shp catchments | psql -d practicePG -q


-- createdb -U postgres <DATABASENAME>
-- psql -U postgres -d <DATABASENAME> -c 'CREATE EXTENSION postgis'

createdb -U postgres practicePG

createdb -U kyle practicePG


-- shp2pgsql -I -s <SRID> <PATH/TO/SHAPEFILE> <SCHEMA>.<DBTABLE> | psql -U postgres -d <DBNAME>

shp2pgsql -I -s 5070 /home/kyle/practice/postGIS/shapefiles/catsWB.shp catchments | psql -U kyle -d practicePG

