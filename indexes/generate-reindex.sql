select 'psql -p <port_number> -c ''reindex index concurrently ' || indexname || ' ;'' <database_name>'
from pg_catalog.pg_indexes 
where schemaname='public'

