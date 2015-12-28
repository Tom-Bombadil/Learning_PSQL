#!/bin/bash
# Returns the locations that fall within the tidally influenced zones
# location table columns [latitude, longitude]

# usage: $ ./id_tidal_sites.sh <db name> <path to covariates folder>
# example: $ ./id_tidal_sites.sh sheds_new


DB=$1


# Add spatial column
psql -d sheds_new -c "ALTER TABLE data.locations ADD COLUMN geom geometry(POINT,4326);"
psql -d sheds_new -c "UPDATE data.locations SET geom = ST_SetSRID(ST_MakePoint(longitude,latitude),4326);"
psql -d sheds_new -c "CREATE INDEX idx_loc_dum_geom ON data.locations USING GIST(geom);"



# Select intersections
psql -d sheds_new -c "SELECT *
						FROM locations, tidal_zones
						WHERE ST_Intersects(locations.geom, tidal_zones.geom);"


#
##
### What happens with the selection? New column? New table? Get group consensus
##
#

