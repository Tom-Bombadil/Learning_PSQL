-- Bash script to setup database
cd "/home/kyle/daymet"
createdb NHDHRDV1_daymet_SusqWest  # Update the database name on this line
./import_daymet.sh NHDHRDV1_daymet_SusqWest # Update the database name on this line too




SELECT * FROM data.daymet WHERE date = '01-01-1980';