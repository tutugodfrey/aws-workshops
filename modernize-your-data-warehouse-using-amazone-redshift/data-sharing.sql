select current_namespace;   -- Run for both cluster to see the namespace

-- Run the the Producer cluster
-- Create Datashare
-- Creating a datashare
-- CREATE DATASHARE cust_share SET PUBLICACCESSIBLE TRUE;

-- -- Adding schema to datashare
-- ALTER DATASHARE cust_share ADD SCHEMA public;

-- -- Adding customer tables to datshares.  We can add all the tables also if required
-- ALTER DATASHARE cust_share ADD TABLE public.customer;

-- -- View shared objects
-- show datashares;
-- select * from SVV_DATASHARE_OBJECTS;

-- -- Granting access to consumer cluster
-- Grant USAGE ON DATASHARE cust_share to NAMESPACE '7a6aa9bd-4d86-4cf2-8594-07bf355864cc';

-- Run in the consumer cluster

-- View shared objects
-- show datashares;
-- select * from SVV_DATASHARE_OBJECTS;

-- -- Create local database
-- CREATE DATABASE cust_db FROM DATASHARE cust_share OF NAMESPACE 'd4ade746-c524-4ada-967d-687b79a76953';

-- -- Select query to check the count
-- select count(*) from cust_db.public.customer; -- count 15000000


-- -- Create orders table in provisioned cluster (consumer).
-- DROP TABLE IF EXISTS orders;
-- create table orders
-- (  O_ORDERKEY bigint NOT NULL,  
-- O_CUSTKEY bigint,  
-- O_ORDERSTATUS varchar(1),  
-- O_TOTALPRICE decimal(18,4),  
-- O_ORDERDATE Date,  
-- O_ORDERPRIORITY varchar(15),  
-- O_CLERK varchar(15),  
-- O_SHIPPRIORITY Integer,  O_COMMENT varchar(79))
-- distkey (O_ORDERKEY)
-- sortkey (O_ORDERDATE);

-- -- Load orders table from public data set
-- copy orders from 's3://redshift-immersionday-labs/data/orders/orders.tbl.'
-- iam_role default region 'us-west-2' lzop delimiter '|' COMPUPDATE PRESET;

-- -- Select count to verify the data load
-- select count(*) from orders;  -- count 76000000

-- SELECT c_mktsegment, o_orderpriority, sum(o_totalprice)
-- FROM cust_db.public.customer c
-- JOIN orders o on c_custkey = o_custkey
-- GROUP BY c_mktsegment, o_orderpriority;

show model model_bank_marketing;

