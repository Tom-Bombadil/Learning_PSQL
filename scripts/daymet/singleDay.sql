psql daymet06





-- Select variables for all FEATUREIDs from a single day
SELECT FEATUREID, tmax, prcp, swe INTO singleDay FROM data.daymet WHERE date = '2014-01-01';	
	
-- Export the record as a CSV
\copy singleDay TO '/home/kyle/daymet/singleDay.csv' DELIMITER ',' CSV HEADER;




-- TESTING OTHER SCENARIOS
-- =======================

-- Select days where snowfall occurred
SELECT DISTINCT date FROM data.daymet WHERE tmax < 0 AND prcp > 0 ;

-- Create a table to populate with climate data
CREATE TABLE testTable (
	FEATUREID	int,
	tmax	real);
	
-- Insert multiple rows of data into a single column
INSERT INTO testTable(FEATUREID) SELECT DISTINCT FEATUREID FROM data.daymet;
