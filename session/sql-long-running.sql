
select * from
(
SELECT
  pid,
  datname,
  now() - pg_stat_activity.query_start AS duration,
  query,
  state
FROM pg_stat_activity
where state <> 'idle'
) t 
order by duration desc;
