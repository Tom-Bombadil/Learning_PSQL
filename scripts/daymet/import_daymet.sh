#!/bin/bash
#usage: ./import_daymet.sh <db_name>
#example: ./import_daymet.sh sheds_dev

set -eu

DB=$1

# create schema
psql -d $DB -f schema_daymet.sql

# export
echo Streaming data from sqlite to $DB
./export_sqlite.sh | psql -d $DB -c "COPY data.daymet FROM STDIN WITH CSV"

psql -d $DB -c "VACUUM ANALYZE;"