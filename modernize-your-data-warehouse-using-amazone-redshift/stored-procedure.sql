CREATE OR REPLACE PROCEDURE lineitem_incremental()
AS $$
BEGIN

truncate stage_lineitem;  

copy stage_lineitem from 's3://redshift-immersionday-labs/data/lineitem-part/l_orderyear=1998/l_ordermonth=8/'
iam_role default
region 'us-west-2' gzip delimiter '|' COMPUPDATE PRESET;

delete from lineitem using stage_lineitem where stage_lineitem.l_orderkey=lineitem.l_orderkey and stage_lineitem.l_linenumber = lineitem.l_linenumber;

copy stage_lineitem from 's3://redshift-immersionday-labs/data/lineitem-part/l_orderyear=1998/l_ordermonth=3/'
iam_role default
region 'us-west-2' gzip delimiter '|' COMPUPDATE PRESET;

insert into lineitem
select * from stage_lineitem;

END;
$$ LANGUAGE plpgsql;
