#!/usr/bin/env bash

db_password=$1
db_endpoint=$2

sed "s/PG_PASSWORD/'${db_password}'/g" database.sql | PGPASSWORD=$db_password psql -h $db_endpoint -U postgres postgres
