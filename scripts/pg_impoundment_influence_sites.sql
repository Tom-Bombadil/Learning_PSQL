

-- 1. Snap point to high res flowlines
-- 2. Intersect snapped points with impounded areas


SELECT 
   DISTINCT ON (pt_id) 
   pt_id, 
   ln_id, 
   ST_AsText(
     ST_line_interpolate_point(
       ln_geom, 
       ST_line_locate_point(ln_geom, vgeom)
     )
   ) 
 FROM
   (
   SELECT 
     ln.the_geom AS ln_geom, 
     pt.the_geom AS pt_geom, 
     ln.id AS ln_id, 
     pt.id AS pt_id, 
     ST_Distance(ln.the_geom, pt.the_geom) AS d 
   FROM 
     point_table pt, 
     line_table ln 
   WHERE 
     ST_DWithin(pt.the_geom, ln.the_geom, 10.0) 
   ORDER BY
     pt_id,d
   ) AS subquery;
   
   
   
   
   
   
 -- For SHEDS:
 
-- Test Locations
psql -d sheds_new -c "CREATE TABLE data.locations_imp(
                        fid int,
                        id int,
                        latitude real,
                        longitude real
                     );"
 
cd /home/kyle/scripts/db/locations_dummy
./import_locations_imp.sh sheds_new /home/kyle/data/locations_dummy/imp_zone_test_pts.csv	
 
 
-- Test Flowlines (smaller size)
psql -d sheds_new -c "CREATE TABLE gis.imp_flowlines_test(
                        featureid bigint,
						objectid bigint,
                        shape_leng real,
                        lengthkm real,
                        geom geometry NOT NULL
                     );"

--Upload spatial layer
cd /home/kyle/scripts/db/gis/impoundment_zones
./import_detailed_flowlines_imp.sh sheds_new /home/kyle/data/imp_zone
 
 
 
 
 
--Impoundment intersecting
 
 
psql -d sheds_new -c "ALTER TABLE data.locations_imp ADD COLUMN geom geometry(POINT,4326);"
psql -d sheds_new -c "UPDATE data.locations_imp SET geom = ST_SetSRID(ST_MakePoint(longitude,latitude),4326);"
psql -d sheds_new -c "CREATE INDEX idx_loc_imp_geom ON data.locations_imp USING GIST(geom);"
 
 
 -- rename: point_table = locations
 -- rename: line_table = detailed_flowlines
 
SELECT 
   DISTINCT ON (pt_id) 
   pt_id, 
   ln_id, 
   ST_AsText(
     ST_line_interpolate_point(
       ln_geom, 
       ST_line_locate_point(ln_geom, vgeom)    -- <- wtf is this supposed to be??? vgeom?
     )
   ) 
 FROM
   (
   SELECT 
     ln.geom AS ln_geom, 
     pt.geom AS pt_geom, 
     ln.featureid AS ln_id, 
     pt.id AS pt_id, 
     ST_Distance(ln.geom, pt.geom) AS d 
   FROM 
     locations_imp pt, 
     imp_flowlines_test ln 
   WHERE 
     ST_DWithin(pt.geom::geography, ln.geom::geography, 50.0) 
   ORDER BY
     pt_id,d
   ) AS subquery;