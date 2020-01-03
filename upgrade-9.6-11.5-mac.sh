# This script will upgrade a postgres cluster running on Mac Postgresql 9.6 to Mac Postgresql 11.5

PGPASSWORD=postgres /usr/local/Cellar/postgresql/11.5_1/bin/pg_upgrade -U postgres -d /Library/PostgreSQL/9.6/data -D /Library/PostgreSQL/11.5/data -b /Library/PostgreSQL/9.6/bin/  -B /usr/local/Cellar/postgresql/11.5_1/bin/ -v

