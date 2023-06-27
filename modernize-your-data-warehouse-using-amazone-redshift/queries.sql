-- select count(*) from region;

-- select count(*) from nation;

-- select count(*) from orders;

-- COPY customer FROM 's3://redshift-immersionday-labs/data/nation/nation.tbl.'
-- iam_role default
-- region 'us-west-2' lzop delimiter '|' noload;

-- select * from sys_load_error_detail;

-- vacuum delete only orders;

-- select "table", size, tbl_rows, estimated_visible_rows
-- from SVV_TABLE_INFO
-- where "table" = 'orders';

-- vacuum sort only orders;

-- vacuum recluster orders;

-- vacuum recluster orders boost;



-- create table stage_lineitem (
--   L_ORDERKEY bigint NOT NULL,
--   L_PARTKEY bigint,
--   L_SUPPKEY bigint,
--   L_LINENUMBER integer NOT NULL,
--   L_QUANTITY decimal(18,4),
--   L_EXTENDEDPRICE decimal(18,4),
--   L_DISCOUNT decimal(18,4),
--   L_TAX decimal(18,4),
--   L_RETURNFLAG varchar(1),
--   L_LINESTATUS varchar(1),
--   L_SHIPDATE date,
--   L_COMMITDATE date,
--   L_RECEIPTDATE date,
--   L_SHIPINSTRUCT varchar(25),
--   L_SHIPMODE varchar(10),
--   L_COMMENT varchar(44));




SELECT count(*) FROM "dev"."public"."lineitem"; --303008217

-- call lineitem_incremental();