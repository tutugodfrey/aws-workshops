-- create function f_py_greater (a float, b float)
--   returns float
-- stable
-- as $$
--   if a > b:
--     return a
--   return b
-- $$ language plpythonu;

-- select f_py_greater (l_extendedprice, l_discount) from lineitem limit 10

create function f_sql_greater (float, float)
  returns float
stable
as $$
  select case when $1 > $2 then $1
    else $2
  end
$$ language sql;  

select f_sql_greater (l_extendedprice, l_discount) from lineitem limit 10


