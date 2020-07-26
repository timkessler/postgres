-- Reindex progress (postgres 12+)

select 
	round(round(blocks_done * 1.0 /case when blocks_total=0 then 1 else blocks_total end,2) * 100,0) blocks_perc, 
	round(round(tuples_done * 1.0 / case when tuples_total=0 then 1 else tuples_total end, 2) * 100, 0) tuples_perc,
	*  
from 	
	pg_stat_progress_create_index 
;

  
  
