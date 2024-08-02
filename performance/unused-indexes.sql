-- UNUSED INDEXES

-- Get the date of the last reset of the statistics for all databases:
-- select datname, pg_stat_get_db_stat_reset_time(D.oid) AS stats_reset FROM pg_database D;                                                                

-- List indexes that have never been scanned
SELECT 
    ( pg_relation_size(s.indexrelid)) /1024/1024 index_size_mb,
    schemaname,relname table_name,indexrelname index_name, 
    idx_scan,idx_tup_read,idx_tup_fetch,
    ,i.indisunique 
FROM pg_catalog.pg_stat_user_indexes s
    JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
WHERE s.idx_scan = 0-- has never been scanned
AND 0 <>ALL (i.indkey)-- no index column is an expression
--AND NOT i.indisunique -- is not a UNIQUE index
AND NOT EXISTS-- does not enforce a constraint
 (SELECT 1 FROM pg_catalog.pg_constraint c
WHERE c.conindid = s.indexrelid)
AND NOT EXISTS-- is not an index partition
 (SELECT 1 FROM pg_catalog.pg_inherits AS inh
WHERE inh.inhrelid = s.indexrelid)
-- AND schemaname NOT IN ('schemaname')
AND  ( pg_relation_size(s.indexrelid)) /1024/1024 > 20
ORDER BY pg_relation_size(s.indexrelid) DESC;
