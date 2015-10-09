psql NHDHRDV2_daymet_06


-- Select variables for all FEATUREIDs from a single day
SELECT * INTO sampleDays FROM data.daymet 
	WHERE date = '2012-04-15' OR 
		  date = '1985-11-03' OR 
		  date = '1997-07-22' OR 
		  date = '2004-02-29';	
	
-- Export the record as a CSV
\copy sampleDays TO '/home/kyle/daymet/sampleDays.csv' DELIMITER ',' CSV HEADER;

	
	
SELECT * INTO singleDay FROM data.daymet WHERE date = '2012-04-15';		
	
SELECT * FROM daymet WHERE date = '2012-04-15';			
	
-- Export the record as a CSV
\copy singleDay TO '/home/kyle/daymet/singleDay.csv' DELIMITER ',' CSV HEADER;


SELECT * FROM singleDay;


-- ========================================================================================================================================

-- Testing NA values in postrges
-- =============================

psql testNAvals;

SELECT * INTO singleDay FROM data.daymet;	












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
