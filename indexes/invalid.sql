SELECT n.nspname, c.relname
FROM   pg_catalog.pg_class c, pg_catalog.pg_namespace n,
       pg_catalog.pg_index i
WHERE  (i.indisvalid = false OR i.indisready = false) AND
       i.indexrelid = c.oid AND c.relnamespace = n.oid AND
       n.nspname != 'pg_catalog' AND
       n.nspname != 'information_schema' AND
       n.nspname != 'pg_toast'

