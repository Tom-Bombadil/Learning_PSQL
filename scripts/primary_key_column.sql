-- The following scripts shows the primary key column in the 'tablename' table

SELECT a.attname, format_type(a.atttypid, a.atttypmod) AS data_type
FROM   pg_index i
JOIN   pg_attribute a ON a.attrelid = i.indrelid
                     AND a.attnum = ANY(i.indkey)
WHERE  i.indrelid = 'schema.tablename'::regclass
AND    i.indisprimary;
