# locations: data.locations_dummy
# tidal zones: gis.tidal_zones


# Setup table with temperature locations
psql -d sheds_new -c "CREATE TABLE data.locations_dummy(
                        id int,
                        description varchar(20),
						latitude real,
						longitude real,
                        catchment_id bigint
                     );"

-- 
cd /home/kyle/scripts/db/locations_dummy
./import_locations_dummy.sh sheds_new /home/kyle/data/locations_dummy/dummy_locations.csv					 

# Add spatial column
psql -d sheds_new -c "ALTER TABLE data.locations_dummy ADD COLUMN geom geometry(POINT,4326);"
psql -d sheds_new -c "UPDATE data.locations_dummy SET geom = ST_SetSRID(ST_MakePoint(longitude,latitude),4326);"
psql -d sheds_new -c "CREATE INDEX idx_loc_dum_geom ON data.locations_dummy USING GIST(geom);"



# Select intersections
psql -d sheds_new -c "SELECT description, latitude, longitude
						FROM locations_dummy, tidal_zones
						WHERE ST_Intersects(locations_dummy.geom, tidal_zones.geom);"




