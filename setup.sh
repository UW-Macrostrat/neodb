#! /bin/bash

# Database Configuration
export DB_NAME=your_database_name
export DB_USER=your_user_name
export DB_PASSWORD=
export DB_PORT=5432


dropdb -p $DB_PORT -U $DB_USER $DB_NAME

createdb -p $DB_PORT -U $DB_USER $DB_NAME

psql -p $DB_PORT -U $DB_USER -c "CREATE EXTENSION postgis;" $DB_NAME

psql -p $DB_PORT -U $DB_USER -c "CREATE EXTENSION postgis_topology;"

psql --set 'user='$DB_USER -p $DB_PORT -U $DB_USER -f create_database.sql $DB_NAME

psql -p $DB_PORT -U $DB_USER -f fill_tables.sql $DB_NAME
