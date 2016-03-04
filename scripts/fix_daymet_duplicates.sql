-- Sort out duplicate Daymet value issue

-- Found 12410 extra entries (equal to 34 years of record)


SELECT COUNT(*) FROM data.daymet; -- 5,797,614,010


SELECT featureid, date, count(*) INTO data.daymet_duplicates2
FROM data.daymet
GROUP BY featureid, date
HAVING count(*) > 1;


-- TESTING HYDRO REGION 06 RECORDS
-- ===============================

createdb daymet_check

CREATE TABLE daymet_old (
  featureid  bigint,
  date  date,
  tmax  real,
  tmin  real,
  prcp  real,
  dayl  real,
  srad  real,
  vp  real,
  swe  real
);

CREATE TABLE daymet_new (
  featureid  bigint,
  date  date,
  tmax  real,
  tmin  real,
  prcp  real,
  dayl  real,
  srad  real,
  vp  real,
  swe  real
);


-- Upload databases
cd /home/kyle/scripts/db/daymet
./import_daymet_old.sh daymet_check /home/kyle/data/daymet

-- Upload databases
cd /home/kyle/scripts/db/daymet
./import_daymet_new.sh daymet_check /home/kyle/data/daymet

-- Re-create index after deleting it for upload & constraint on duplicates
psql -d daymet_check -c "CREATE INDEX daymet_featureid_year_idx ON daymet_old USING btree (featureid, date_part('year'::text, date));"
psql -d daymet_check -c "CREATE INDEX daymet_new_featureid_year_idx ON daymet_new USING btree (featureid, date_part('year'::text, date));"


-- Original database
SELECT COUNT(*) FROM daymet_old; -- 155,407,510

-- Recalculated database
SELECT COUNT(*) FROM daymet_new; -- 155,395,100

-- The difference is 12,410 rows. This is the number of duplicates in the main database.
--    Re-running the upload with the new SQLite database for hydro-region 06 should. 



