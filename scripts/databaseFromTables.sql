-- In Putty
-- ========

createdb coastal_ct
--enter password

psql coastal_ct
--enter password

-- dropdb practice_db



CREATE TABLE lines 
(OBJECTID int, SOURCE char(20), FEATUREID int, 
NextDownID int, Shape_Length real, LengthKM real);

\copy lines FROM '/home/kyle/practice/coastalCT_lines.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE cats 
(OBJECTID int, Source char(20), FEATUREID int, 
NextDownID int, Shape_Length real, Shape_Area real, AreaSqKM real);

\copy cats FROM '/home/kyle/practice/coastalCT_cats.csv' DELIMITER ',' CSV HEADER;


