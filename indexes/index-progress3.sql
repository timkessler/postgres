
select 
  phase,
	round((round(round(blocks_done * 1.0 /case when blocks_total=0 then 1 else blocks_total end,2) * 100,1) + 
  round(round(tuples_done * 1.0 / case when tuples_total=0 then 1 else tuples_total end, 2) * 100, 1) 
  ) / 2,1 ) total_perc,
	round(round(blocks_done * 1.0 /case when blocks_total=0 then 1 else blocks_total end,2) * 100,1) blocks_perc, 
	round(round(tuples_done * 1.0 / case when tuples_total=0 then 1 else tuples_total end, 2) * 100, 1) tuples_perc
	--s1.query as reindex_query,
	--s2.query blocking_query
	--index_progress.*  
from 	
	pg_stat_progress_create_index index_progress
	join pg_stat_activity s1 on index_progress.pid= s1.pid
	left outer join (
			SELECT blocked_locks.pid     AS blocked_pid,
		         blocked_activity.usename  AS blocked_user,
		         blocking_locks.pid     AS blocking_pid,
		         blocking_activity.usename AS blocking_user,
		         blocked_activity.query    AS blocked_statement,
		         blocking_activity.query   AS current_statement_in_blocking_process
		   FROM  pg_catalog.pg_locks         blocked_locks
		    JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
		    JOIN pg_catalog.pg_locks         blocking_locks 
		        ON blocking_locks.locktype = blocked_locks.locktype
		        AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
		        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
		        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
		        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
		        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
		        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
		        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
		        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
		        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
		        AND blocking_locks.pid != blocked_locks.pid
		    JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
		   WHERE NOT blocked_locks.granted
	) blockers on s1.pid=blockers.blocked_pid
	left outer join pg_stat_activity s2 on index_progress.pid= s2.pid
	;
