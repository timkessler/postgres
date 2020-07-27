PGPASSWORD=password pg_dump --port 20001 --host localhost --username postgres --schema-only --format=plain --file /tmp/ddl.sql database_name
