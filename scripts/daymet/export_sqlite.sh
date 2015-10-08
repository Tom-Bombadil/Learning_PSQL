#!/bin/bash
sqlite3 NHDHRDV2_06 <<!
.mode csv
.output stdout
select * from climateRecord;
!