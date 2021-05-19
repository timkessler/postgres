/pset pager off

echo  ******************************************************************************************************************************************************
echo Rank By Average seconds:
echo - What can be cached in application?
echo ******************************************************************************************************************************************************

select * from (
select 
--datname,
rank() over ( order by total_time/calls desc) rank_avg_seconds, 
round( cast((total_time/calls)/1000 as numeric),2) avg_seconds, 
calls,
	round(total_time/1000) total_seconds, 
rank() over ( order by total_time desc) rank_total_seconds ,
rows, 
substr(query,1,400) as "query (truncated)"
--query
from  pg_stat_statements t1 
join pg_database t2 on (t1.dbid=t2.oid)
where query not like 'COPY%'
and max_time < 1000000
order by avg_seconds desc
) t1 
order by rank_avg_seconds 
limit 40;

echo  ******************************************************************************************************************************************************
echo Rank By Total seconds:
echo ******************************************************************************************************************************************************

SELECT * FROM (SELECT  sum(total_time) OVER () / 1000 total_time, rank() OVER ( ORDER BY total_time DESC) rank_total_seconds ,
round(total_time/1000) total_seconds, calls,
round( CAST((total_time/calls) AS NUMERIC),1) avg_ms, 
rank() OVER ( ORDER BY total_time/calls DESC) rank_avg_seconds, 
ROWS, 
round((CAST (max_time::DOUBLE PRECISION/1000 AS DOUBLE PRECISION))::NUMERIC,3) max_time_seconds,
round((CAST (min_time::DOUBLE PRECISION/1000 AS DOUBLE PRECISION))::NUMERIC,3) min_time_seconds,
--query
substr(QUERY,1,400)  AS "query (truncated)"
FROM pg_stat_statements -- pg_stat_statements t1 
WHERE query not like '%pg_%' and QUERY NOT LIKE 'COPY%' AND QUERY NOT LIKE 'CREATE%' AND QUERY NOT LIKE 'ALTER%' AND QUERY NOT LIKE 'SET application_name%' 
AND calls > 1
ORDER BY total_seconds DESC
) t2 
--where avg_seconds > .2
ORDER BY rank_total_seconds
LIMIT 10
;



echo ******************************************************************************************************************************************************
echo Extrapolated Annual Customer Value for Top 10 queries (based on wage average increments) 
echo ******************************************************************************************************************************************************

with 
	c1 as (select now() - pg_postmaster_start_time() as time_since_startup),
	c2 as (select extract(epoch from (time_since_startup)) as seconds_since_startup from c1),
	c3 as (select seconds_since_startup/ (60*60*24) as hours_since_startup from c2),
	constants as (select (36500.0 / cast ((hours_since_startup * 100) as integer)) as extrapolate_to_annual from c3 )
select  
	cast((total_hours * extrapolate_to_annual / 12) as integer) as monthly_hours_top10_sql,
	cast((total_hours * extrapolate_to_annual) as integer) as annual_hours_top10_sql,
	cast(cast((total_hours *  8 * extrapolate_to_annual) as integer) as money)  as annual_customer_value_wage_8dph,
	cast(cast((total_hours * 10 * extrapolate_to_annual) as integer) as money)  as annual_customer_value_wage_10dph,
	cast(cast((total_hours * 12 * extrapolate_to_annual) as integer) as money)  as annual_customer_value_wage_12dph,
	cast(cast((total_hours * 14 * extrapolate_to_annual) as integer) as money)  as annual_customer_value_wage_14dph
from constants 
cross join 
(
	select  
		sum(total_seconds) / 60 / 60 total_hours
	from 

	(
		SELECT * FROM (
			SELECT  
				round(total_time/1000) total_seconds
			FROM pg_stat_statements 
			WHERE query not like '%pg_%' and QUERY NOT LIKE 'COPY%' AND QUERY NOT LIKE 'CREATE%' AND QUERY NOT LIKE 'ALTER%' 
			AND QUERY NOT LIKE 'SET application_name%' 
			AND calls > 1
			ORDER BY total_seconds DESC
		) t2 
	LIMIT 10
	) t3
) t2
;



echo ******************************************************************************************************************************************************
echo Rank By # calls:
echo ******************************************************************************************************************************************************


select * from (
SELECT * FROM (SELECT dbid, rank() OVER ( ORDER BY calls DESC) rank_calls, ---
round( CAST((total_time/calls)/1000 AS NUMERIC),3) avg_seconds, calls, round(total_time/1000) total_seconds, 
rank() OVER ( ORDER BY total_time DESC) rank_total_seconds ,
rank() OVER ( ORDER BY total_time/calls DESC) rank_avg_seconds, ROWS, 
substr(QUERY,1,400) AS "query (truncated)"
--query
FROM pg_stat_statements t1 -- pg_stat_statements t1 
WHERE QUERY <> 'COMMIT' AND QUERY NOT LIKE 'SET application_name%' AND QUERY NOT LIKE 'COPY%'AND QUERY NOT LIKE 'CREATE%' AND QUERY NOT LIKE 'ALTER%' and QUERY <> 'BEGIN' and QUERY <> 'SELECT ?' 
--and query like '%claims%'
--and dbid not in (1073152)
) t1 
--WHERE avg_seconds > .01 
ORDER BY rank_calls ASC
) t 
limit 40
;

echo ******************************************************************************************************************************************************
echo Rank By Rows Returned:
echo ******************************************************************************************************************************************************


SELECT * FROM (SELECT ROWS, 
rank() OVER ( ORDER BY calls DESC) rank_calls, ---
round( CAST((total_time/calls)/1000 AS NUMERIC),5) avg_seconds, calls, round(total_time/1000) total_seconds, 
rank() OVER ( ORDER BY total_time DESC) rank_total_seconds ,
rank() OVER ( ORDER BY total_time/calls DESC) rank_avg_seconds, 
substr(QUERY,1,400) AS "query (truncated)"
--query
FROM pg_stat_statements t1 -- pg_stat_statements t1 
WHERE QUERY <> 'COMMIT'
AND QUERY NOT LIKE 'SET application_name%' AND QUERY NOT LIKE 'COPY%' AND QUERY NOT LIKE 'CREATE%' AND QUERY NOT LIKE 'ALTER%' AND QUERY <> 'BEGIN'
--and calls > 20
--and round( cast((total_time/calls)/1000 as numeric),2) > .5
--and query like '%patient_assignment_metadata%agency_id%user_id%patient_id%'
--and query like '%evvs%'
and query like '%clinical_chart%'
--and dbid not in (1073152)
) t1 
ORDER BY ROWS DESC
limit 40
;

