select calls, 
substr(query,1,100) query_first_100, 
substr(query, 
    position ('WHERE' in query) + 7, 
    length(query) - position ('WHERE' in query) + 7
    ) query_where_clause  
from pg_stat_statements;
