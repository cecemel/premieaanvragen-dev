#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"
export POSTGRES_DB="premieaanvragen"

psql -U "$POSTGRES_USER" -c "ALTER USER postgres SET timezone='Europe/Brussels';"

#create projects-db for projects_service
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE $POSTGRES_DB;
    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
    CREATE ROLE premieaanvragen_dml;
    CREATE ROLE pgvioe;
    CREATE ROLE premieaanvragen_ddl;
    CREATE ROLE vioedba;
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in "$POSTGRES_DB"; do
  echo "Loading PostGIS extensions into $DB"
  "${psql[@]}" --dbname="$DB" <<-'EOSQL'
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS postgis_topology;
    CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
    CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL
done

for DB in "$POSTGRES_DB"; do
    echo "workaround for https://github.com/appropriate/docker-postgis/issues/58"
  "${psql[@]}" --dbname="$DB" <<-'EOSQL'
    ALTER EXTENSION postgis UPDATE;
    ALTER EXTENSION postgis_topology UPDATE;
EOSQL
done

# create test DB
export POSTGRES_DB="premieaanvragen_test"

#create projects-db for projects_service
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE $POSTGRES_DB;
    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in "$POSTGRES_DB"; do
  echo "Loading PostGIS extensions into $DB"
  "${psql[@]}" --dbname="$DB" <<-'EOSQL'
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS postgis_topology;
    CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
    CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL
done

for DB in "$POSTGRES_DB"; do
    echo "workaround for https://github.com/appropriate/docker-postgis/issues/58"
  "${psql[@]}" --dbname="$DB" <<-'EOSQL'
    ALTER EXTENSION postgis UPDATE;
    ALTER EXTENSION postgis_topology UPDATE;
EOSQL
done
