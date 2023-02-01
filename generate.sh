#!/bin/sh

# constants

jsondir=generated/json
sqldir=generated/sql

# define number of test data rows

regions=5
countries=10
locations=45
jobs=15
departments=15
managers=25
employees=150
dependents=35

# generate JSON files

python datagen.py templates/json/regions.json.jinja2 --count $regions --output $jsondir/regions.json
python datagen.py templates/json/countries.json.jinja2 --count $countries --data $jsondir/regions.json --output $jsondir/countries.json
python datagen.py templates/json/locations.json.jinja2 --count $locations --data $jsondir/countries.json --output $jsondir/locations.json
python datagen.py templates/json/jobs.json.jinja2 --count $jobs --output $jsondir/jobs.json
python datagen.py templates/json/departments.json.jinja2 --count $departments --data $jsondir/locations.json --output $jsondir/departments.json
python datagen.py templates/json/managers.json.jinja2 --count $managers --data $jsondir/departments.json,$jsondir/jobs.json --output $jsondir/managers.json
python datagen.py templates/json/employees.json.jinja2 --count $employees --data $jsondir/departments.json,$jsondir/managers.json,$jsondir/jobs.json --output $jsondir/employees.json
python datagen.py templates/json/dependents.json.jinja2 --count $dependents --data $jsondir/employees.json --output $jsondir/dependents.json

# generate SQL files

python datagen.py templates/sql/insert.sql.jinja2 --data $jsondir/regions.json --output $sqldir/001_insert_regions.sql
python datagen.py templates/sql/insert.sql.jinja2 --data $jsondir/countries.json --output $sqldir/002_insert_countries.sql
python datagen.py templates/sql/insert.sql.jinja2 --data $jsondir/locations.json --output $sqldir/003_insert_locations.sql
python datagen.py templates/sql/insert.sql.jinja2 --data $jsondir/jobs.json --output $sqldir/004_insert_jobs.sql
python datagen.py templates/sql/insert.sql.jinja2 --data $jsondir/departments.json --output $sqldir/005_insert_departments.sql
python datagen.py templates/sql/insert.sql.jinja2 --data $jsondir/managers.json --output $sqldir/006_insert_managers.sql
python datagen.py templates/sql/insert.sql.jinja2 --data $jsondir/employees.json --output $sqldir/007_insert_employees.sql
python datagen.py templates/sql/insert.sql.jinja2 --data $jsondir/dependents.json --output $sqldir/008_insert_dependents.sql

# merge all sql files

rm $sqldir/ZZZ_insert_all.sql
cat $sqldir/*.sql >> $sqldir/ZZZ_insert_all.sql