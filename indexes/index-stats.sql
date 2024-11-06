SELECT relname, n_live_tup, n_dead_tup, *
FROM pg_stat_user_tables
-- where relname='<relname>'
ORDER BY n_dead_tup DESC;
