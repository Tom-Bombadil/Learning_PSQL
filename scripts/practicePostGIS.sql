createdb practicePG

psql practicePG

CREATE EXTENSION postgis;
SELECT postgis_full_version();

shp2pgsql -I -s 5070:5070 /home/kyle/practice/postGIS/shapefiles/catsWB.shp catchments | psql -U kyle -d practicePG;
















-- =============
-- General Tasks
-- =============

select * from pg_indexes where tablename = 'covariates';




SELECT a.attname, format_type(a.atttypid, a.atttypmod) AS data_type
FROM   pg_index i
JOIN   pg_attribute a ON a.attrelid = i.indrelid
                     AND a.attnum = ANY(i.indkey)
WHERE  i.indrelid = 'wbdhu12'::regclass
AND    i.indisprimary;

select * from (
  SELECT huc12,
  ROW_NUMBER() OVER(PARTITION BY huc12 ORDER BY huc12 asc) AS Row
  FROM wbdhu12
) dups
where 
dups.Row > 1;

select fid, huc12 from wbdhu12 where huc12 = '040201010102';


select * from pg_indexes where tablename = 'wbdhu12';

-- Check constraints in a table
select * from information_schema.table_constraints where table_name='catchments';
select * from information_schema.table_constraints where table_name='covariates';
select * from information_schema.table_constraints where table_name='catchment_huc12';
select * from information_schema.table_constraints where table_name='wbdhu12';


-- Check columns in a table
select column_name, data_type from information_schema.columns where table_name = 'catchments';
select column_name, data_type from information_schema.columns where table_name = 'covariates';
select column_name, data_type from information_schema.columns where table_name = 'catchment_huc12';
select column_name, data_type from information_schema.columns where table_name = 'temp.testhu12';
select column_name, data_type from information_schema.columns where table_name = 'wbdhu12';

select column_name, data_type from information_schema.columns where table_name = 'gis.impoundment_zones_100m';

-- Workflow
-- ========


psql -c "CREATE DATABASE practice WITH TEMPLATE sheds_new OWNER kyle;"

cd /home/kyle/scripts
./import_catchments.sh practice /home/kyle/data/gis/catchments

cd /home/kyle/scripts
./import_catchments.sh practice /home/kyle/practice/postGIS/shapefiles

-- Check columns
select column_name, data_type from information_schema.columns where table_name = 'catchments';
select column_name, data_type from information_schema.columns where table_name = 'daymet';


-- relation "catchments_geom_gist" already exists


select gid, objectid, shape_leng, shape_area, hydroid, gridid, nextdownid, riverorder, featureid, areasqkm, source from gis.catchments;
select featureid, shape_leng, lengthkm from gis.detailed_flowlines;
select featureid, shape_leng, lengthkm from gis.truncated_flowlines;






DROP INDEX daymet_featureid_fkey;
DROP INDEX daymet_featureid_year_idx;
DELETE FROM data.daymet;











#-sql "SELECT Source, FEATUREID, NextDownID, Shape_Leng, Shape_Area, AreaSqKM FROM catsWB"


#psql -c "CREATE INDEX name ON $TABLE USING gist(geom);"


CREATE INDEX geom_index ON gis.catchments USING gist(geom);





select * from pg_indexes where tablename = 'gis.catchments';















------------------------------------------------------------------












-- Set up new database from scratch
-- ================================





ALTER TABLE catchments ALTER COLUMN featureid real;
ALTER TABLE catchments ALTER COLUMN nextdownid numeric;



createdb practicePG

psql practicePG

CREATE EXTENSION postgis;
SELECT postgis_full_version();

CREATE TABLE weather (
    city            varchar(80),
    temp_lo         int,           -- low temperature
    temp_hi         int,           -- high temperature
    prcp            real,          -- precipitation
    date            date
);

FID
Shape
OBJECTID
Source
FEATUREID
NextDownID
Shape_Leng
Shape_Area
AreaSqKM
















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

