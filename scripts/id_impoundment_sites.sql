-- Add spatial column to locations table
ALTER TABLE public.locations_test ADD COLUMN geom geometry(POINT,4326);
UPDATE public.locations_test SET geom = ST_SetSRID(ST_MakePoint(longitude,latitude),4326);
CREATE INDEX idx_loc_dum_geom ON public.locations_test USING GIST(geom);







ALTER TABLE locations_test ADD PRIMARY KEY (id);



-- Select locations that intersect
SELECT locations_test.id, created_at, updated_at, name, description, latitude, longitude, agency_id, catchment_id
  FROM public.locations_test, gis.impoundment_zones_100m
  WHERE ST_Intersects(ST_Buffer(public.locations_test.geom::geography, 50), gis.impoundment_zones_100m.geom);
  

ST_Buffer(public.locations_test.geom::geography, 50)  
  
  
  
  ST_SetSRID(ST_MakePoint(longitude,latitude),4326);
CREATE INDEX idx_loc_dum_geom ON public.locations_test USING GIST(geom);