WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT
    cp.usecounts AS ExecutionCount,
    st.text AS SQLText,
    qp.query_plan AS QueryPlan
FROM
    sys.dm_exec_cached_plans AS cp
    CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
    CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
WHERE
    qp.query_plan.exist('//ScalarOperator[@ScalarString[contains(., "CONVERT_IMPLICIT")]]') = 1;
