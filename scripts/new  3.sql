
-- Daymet Practice




select column_name, data_type from information_schema.columns where table_name = 'daymet';


select column_name, data_type from information_schema.columns where table_name = 'hrd_flowlines';
select column_name, data_type from information_schema.columns where table_name = 'flowlines';
select column_name, data_type from information_schema.columns where table_name = 'catchments';

select * from data.daymet where date = '1980-01-01';
select * from data.daymet where featureid = 201480645;
select * from data.daymet where featureid = 2011176674;