# Data Transformation and Querying n Amazon Redshift

Resources

* [Creating materialized views n Amazon Redshift](https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-overview.html)
* [Scheduling a query](https://docs.aws.amazon.com/redshift/latest/mgmt/query-editor-schedule-query.html)
* [Scheduling SQL queries on your Amazon Redshift data warehouse](https://aws.amazon.com/blogs/big-data/scheduling-sql-queries-on-your-amazon-redshift-data-warehouse/)
* [Overview of data sharing in Amazon Redshift](https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-overview.html)


RedshiftRole

- glue-policy

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "athena:Batch*",
                "athena:Create*",
                "athena:Delete*",
                "athena:Get*",
                "athena:List*",
                "athena:Start*",
                "athena:Stop*",
                "athena:TagResource",
                "athena:UntagResource",
                "athena:Update",
                "glue:BatchCreatePartition",
                "glue:BatchDeleteTableVersion",
                "glue:BatchGetCrawlers",
                "glue:BatchGetDevEndpoints",
                "glue:BatchGetJobs",
                "glue:BatchGetPartition",
                "glue:BatchGetTriggers",
                "glue:BatchGetWorkflows",
                "glue:CreateDatabase",
                "glue:CreateTable",
                "glue:DeleteTableVersion",
                "glue:DeleteTable",
                "glue:Get*",
                "glue:List*",
                "glue:SearchTables"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

- s3-policy

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1kn75hwf6bww6/*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:List*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```

Role trust policy

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "redshift.amazonaws.com",
                    "glue.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

```bash
CREATE EXTERNAL SCHEMA spectrum
FROM DATA CATALOG
DATABASE spectrumdb
IAM_ROLE 'arn:aws:iam::033155433876:role/RedshiftRole'
CREATE EXTERNAL DATABASE IF NOT EXISTS;


DROP TABLE IF EXISTS spectrum.stocksummary;
CREATE EXTERNAL TABLE spectrum.stocksummary(
    Trade_Date VARCHAR(15),
    Ticker VARCHAR(5),
    High DECIMAL(8,2),
    Low DECIMAL(8,2),
    Open_value DECIMAL(8,2),
    Close DECIMAL(8,2),
    Volume DECIMAL(15),
    Adj_Close DECIMAL(8,2)
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1kn75hwf6bww6/data/';

SELECT * FROM spectrum.stocksummary
    WHERE trade_date = '2020-01-03'
    ORDER BY trade_date ASC, ticker ASC;

# Create materialized view

DROP MATERIALIZED VIEW IF EXISTS stocks_mv;
CREATE MATERIALIZED VIEW stocks_mv AS
    SELECT trade_date, ticker, volume FROM spectrum.stocksummary;

SELECT * FROM stocks_mv
    WHERE trade_date = '2020-01-03'
    ORDER BY trade_date ASC, ticker ASC;


WITH tmp_variables AS (
SELECT 
   '2020-10-03'::DATE AS StartDate
)
   
SELECT
    ticker,
    SUM(volume) AS sum_volume
FROM stocks_mv
WHERE trade_date BETWEEN (SELECT StartDate FROM tmp_variables)-7 AND (SELECT StartDate FROM tmp_variables)
GROUP BY ticker
ORDER BY sum_volume DESC
LIMIT 3;


CREATE DATASHARE stocks_share;
ALTER DATASHARE stocks_share ADD SCHEMA public;
ALTER DATASHARE stocks_share ADD SCHEMA public;
ALTER DATASHARE stocks_share ADD TABLE public.stocks_mv;
GRANT USAGE ON DATASHARE stocks_share to NAMESPACE '6ac484b1-0399-498e-8343-89fe3a36a574';
SELECT * FROM svv_datashares;
SELECT * FROM svv_datashare_objects;
SELECT * FROM svv_datashare_consumers;
```

Consumer accessing the Datashare

```bash
psql -U dbadmin -h consumer-cluster.cdrkvwupsh8z.us-east-1.redshift.amazonaws.com -p 5439 -d consumer_stocks
SELECT * FROM svv_datashares;
SELECT * FROM svv_datashare_objects;
CREATE DATABASE stock_summary FROM DATASHARE stocks_share of NAMESPACE 'ca3314a9-772b-420b-b9fb-bd5949aa084a';

SELECT * FROM stock_summary.public.stocks_mv
    WHERE trade_date = '2020-01-03'
    ORDER BY trade_date ASC, ticker ASC;

```

Revoke access to the share

```bash
REVOKE USAGE ON DATASHARE stocks_share FROM NAMESPACE '6ac484b1-0399-498e-8343-89fe3a36a574';
```

```bash
CREATE EXTERNAL SCHEMA spectrum
FROM DATA CATALOG
DATABASE spectrumdb
IAM_ROLE 'arn:aws:iam::599756913453:role/RedshiftRole'
CREATE EXTERNAL DATABASE IF NOT EXISTS;



DROP TABLE IF EXISTS spectrum.stocksummary;
CREATE EXTERNAL TABLE spectrum.stocksummary(
    Trade_Date VARCHAR(15),
    Ticker VARCHAR(5),
    High DECIMAL(8,2),
    Low DECIMAL(8,2),
    Open_value DECIMAL(8,2),
    Close DECIMAL(8,2),
    Volume DECIMAL(15),
    Adj_Close DECIMAL(8,2)
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1uhvqlfxwhb4g/data/';

SELECT * FROM spectrum.stocksummary
    WHERE trade_date = '2020-01-03'
    ORDER BY trade_date ASC, ticker ASC;

DROP MATERIALIZED VIEW IF EXISTS stocks_mv;
CREATE MATERIALIZED VIEW stocks_mv AS
    SELECT trade_date, ticker, volume FROM spectrum.stocksummary;


SELECT * FROM stocks_mv
    WHERE trade_date = '2020-01-03'
    ORDER BY trade_date ASC, ticker ASC;

WITH tmp_variables AS (
SELECT 
   '2020-10-03'::DATE AS StartDate
)
   
SELECT
    ticker,
    SUM(volume) AS sum_volume
FROM stocks_mv
WHERE trade_date BETWEEN (SELECT StartDate FROM tmp_variables)-7 AND (SELECT StartDate FROM tmp_variables)
GROUP BY ticker
ORDER BY sum_volume DESC
LIMIT 3;

```

## Creating Data shares

```bash
CREATE DATASHARE stocks_share;
ALTER DATASHARE stocks_share ADD SCHEMA public;
ALTER DATASHARE stocks_share ADD TABLE public.stocks_mv;
GRANT USAGE ON DATASHARE stocks_share to NAMESPACE '82b8f639-5a95-4ef7-b6c5-99f83e3e81b2';    # naemspace is consumer namespace
SELECT * FROM svv_datashares;
SELECT * FROM svv_datashare_objects;
SELECT * FROM svv_datashare_consumers;

## Revoking access to share. When the consumer no longer need access to the datashare, you can revoke the access as shown below
REVOKE USAGE ON DATASHARE stocks_share FROM NAMESPACE '82b8f639-5a95-4ef7-b6c5-99f83e3e81b2'; # Namespace is the namespace of the consumer
```

# Consumer using the Data share

```bash
SELECT * FROM svv_datashares;
SELECT * FROM svv_datashare_objects;
SELECT * FROM svv_datashare_consumers;      # Nothing at this point because the cluster is not shareing any data
CREATE DATABASE stock_summary FROM DATASHARE stocks_share of NAMESPACE 'e405d5bf-ae79-4df1-abac-9c7ca56bc6f7';   ## the namespace is the consumer namespace

SELECT * FROM stock_summary.public.stocks_mv
    WHERE trade_date = '2020-01-03'
    ORDER BY trade_date ASC, ticker ASC;

```

Twicking it

```bash
DROP MATERIALIZED VIEW IF EXISTS my_mv;
CREATE MATERIALIZED VIEW my_mv AS
    SELECT trade_date, low, close, volume FROM spectrum.stocksummary;

select * from my_mv Limit 10;

# Notice we are adding the new materialized view table to already existing data share - stocks_share
ALTER DATASHARE stocks_share ADD TABLE public.my_mv;


## The consumer already have access to the data share hence can read the new table
SELECT * FROM stock_summary.public.my_mv limit 10;    ### On the consumer side
```

