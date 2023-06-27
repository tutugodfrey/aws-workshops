-- select n_name, s_name, l_shipmode,
-- SUM(L_QUANTITY) Total_Qty
-- from lineitem
-- join supplier on l_suppkey = s_suppkey
-- join nation on s_nationkey = n_nationkey
-- where datepart(year, L_SHIPDATE) > 1997
-- group by 1,2,3
-- order by 3 desc
-- limit 1000;

-- CREATE MATERIALIZED VIEW supplier_shipmode_agg
-- AUTO REFRESH YES AS
-- select l_suppkey, l_shipmode, datepart(year, L_SHIPDATE) l_shipyear,
--   SUM(L_QUANTITY)	TOTAL_QTY,
--   SUM(L_DISCOUNT) TOTAL_DISCOUNT,
--   SUM(L_TAX) TOTAL_TAX,
--   SUM(L_EXTENDEDPRICE) TOTAL_EXTENDEDPRICE  
-- from LINEITEM
-- group by 1,2,3;

-- explain
-- select n_name, s_name, l_shipmode,
-- SUM(L_QUANTITY) Total_Qty
-- from lineitem
-- join supplier on l_suppkey = s_suppkey
-- join nation on s_nationkey = n_nationkey
-- where datepart(year, L_SHIPDATE) > 1997
-- group by 1,2,3
-- order by 3 desc
-- limit 1000;

-- select SUM(TOTAL_QTY) Total_Qty from supplier_shipmode_agg;

-- delete from lineitem
-- using orders
-- where l_orderkey = o_orderkey
-- and datepart(year, o_orderdate) = 1998 and datepart(month, o_orderdate) = 8;

-- select SUM(TOTAL_QTY) Total_Qty from supplier_shipmode_agg;

create function f_py_greater (a float, b float)
  returns float
stable
as $$
  if a > b:
    return a
  return b
$$ language plpythonu;

select f_py_greater (l_extendedprice, l_discount) from lineitem limit 10
