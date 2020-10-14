-- Number of elements on the jsonb object:

select id, jsonb_array_length(datab) from data.items;
