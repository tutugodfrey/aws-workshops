# Data Analytics Using Amazon Redshift Spectrum

Resources

* [Amazon Redshift Documentation](https://docs.aws.amazon.com/redshift/index.html)
* [What is Amazon Aurora?](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html)
* [What is AWS Secret Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html)
* [Configure session preferences](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-configure-preferences.html)
* [UNLOAD](https://docs.aws.amazon.com/redshift/latest/dg/r_UNLOAD.html)
* [Using the Amazon Redshift Data API](https://docs.aws.amazon.com/redshift/latest/mgmt/data-api.html)

```bash
export HOST=$(aws rds describe-db-clusters | jq '.DBClusters[0].Endpoint' | tr -d '"')
export username=$(aws rds describe-db-clusters | jq '.DBClusters[0].MasterUsername' | tr -d '"')
export dbname=$(aws rds describe-db-clusters | jq '.DBClusters[0].DatabaseName' | tr -d '"')

psql -U $username -h $HOST -password $PGPASSWORD -p 5432 -d $dbname
psql -U $username -h $HOST -password $PGPASSWORD -d $dbname -p 5432 -f /home/ec2-user/db.sql
psql -U $username -d $dbname -h $HOST -p 5432 -c '\COPY stocks FROM '' /home/ec2-user/stocks.csv'' CSV HEADER'


SELECT * FROM stocks WHERE Trade_Date LIKE '2019-01-03' ORDER BY Ticker;
```

db.sql

```bash
CREATE SCHEMA IF NOT EXISTS stocksummary;

CREATE TABLE IF NOT EXISTS stocks (
    Trade_Date VARCHAR(15) NOT NULL,
    Ticker VARCHAR(15) NOT NULL,
    High DECIMAL(8,2) NOT NULL,
    Low DECIMAL(8,2) NOT NULL,
    Open DECIMAL(8,2) NOT NULL,
    Close DECIMAL(8,2) NOT NULL,
    Volume DECIMAL(15) NOT NULL,
    Adj_Close DECIMAL(8,2) NOT NULL
);
```

Connect to RedShift 

```bash

CREATE EXTERNAL SCHEMA spectrum
FROM DATA CATALOG
DATABASE 'spectrum'
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
LOCATION 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1qbmu8r6ni0ee/data/';


SELECT * FROM spectrum.stocksummary WHERE Trade_Date LIKE '2021-09-09' ORDER BY Ticker;
```

```bash
CREATE EXTERNAL SCHEMA federated
FROM POSTGRES
DATABASE 'stocksummary'
URI 'labstack-bbcae2a4-d4fc-4b93-92cd-d6a-auroracluster-cu2if1uifwvr.cluster-czswvurxo3c0.us-west-2.rds.amazonaws.com'
IAM_ROLE 'arn:aws:iam::599756913453:role/RedshiftRole'
SECRET_ARN 'arn:aws:secretsmanager:us-west-2:599756913453:secret:AuroraSecrets-ytyyru';

SELECT * FROM federated.stocks WHERE Trade_Date LIKE '2021-09-09' ORDER BY Ticker;

```

Unload query results to Amazon S3

```bash
UNLOAD ('SELECT * FROM federated.stocks ORDER BY Trade_Date')
TO 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1qbmu8r6ni0ee/unload/stocks_' 
IAM_ROLE 'arn:aws:iam::599756913453:role/RedshiftRole'
PARQUET
maxfilesize 5 mb
ALLOWOVERWRITE;
```

## Use the Amazon Redshift Data API to interact with Redshift clusters

```bash
aws redshift-data execute-statement \
     --database lab  \
     --cluster-identifier redshiftcluster \
     --secret-arn $RedshiftSecretArn \
     --sql "CREATE SCHEMA data_api_demo;" \
     --region $Region

aws redshift-data describe-statement --id '<INSERT_RUN_ID>'       # REPLACE INSERT_RUN_ID with the Id output from the above command
aws redshift-data describe-statement --id '9b0f088b-b5af-44cf-a5e2-c4fee8208bcc' 

aws redshift-data execute-statement \
    --database lab \
    --cluster-identifier redshiftcluster \
    --secret-arn $RedshiftSecretArn  \
    --region $Region \
    --sql "CREATE TABLE data_api_demo.stocks_da (
        Trade_Date VARCHAR(15),
        Ticker VARCHAR(5),
        High DECIMAL(8,2),
        Low DECIMAL(8,2),
        Open_value DECIMAL(8,2),
        Close DECIMAL(8,2),
        Volume DECIMAL(15),
        Adj_Close DECIMAL(8,2)
        )"


aws redshift-data execute-statement \
    --database lab \
    --cluster-identifier redshiftcluster \
    --secret-arn $RedshiftSecretArn \
    --region $Region \
    --sql "COPY data_api_demo.stocks_da
          FROM 's3://$DataBucket/data/stock_prices.csv'
          IAM_ROLE '$RedshiftRoleArn'
          DATEFORMAT 'auto'
          IGNOREHEADER 1
          DELIMITER ','
          IGNOREBLANKLINES;"


aws redshift-data execute-statement \
    --database lab \
    --cluster-identifier redshiftcluster \
    --secret-arn $RedshiftSecretArn \
    --region $Region \
    --sql "select ticker, count(*)
          from data_api_demo.stocks_da
          where close > open_value
          and trade_date > '2020-01-01'
          group by ticker
          order by count(*) desc;"

aws redshift-data get-statement-result --id '<INSERT_RUN_ID>'
aws redshift-data get-statement-result --id 'b5ab0f49-6c65-4635-9a70-7f4d2112fda0'


aws redshift-data get-statement-result --id 'b5ab0f49-6c65-4635-9a70-7f4d2112fda0' --output table

```

FROM Redshift command prompt

```bash
select ticker, count(*) from data_api_demo.stocks_da
    where close > open_value
    and trade_date > '2020-01-01'
    group by ticker
    order by count(*) desc;
```


```bash
CREATE EXTERNAL SCHEMA spectrum
FROM DATA CATALOG
DATABASE 'spectrumdb'
IAM_ROLE 'arn:aws:iam::783152459493:role/RedshiftRole'
CREATE EXTERNAL DATABASE IF NOT EXISTS;

CREATE EXTERNAL SCHEMA myowndb
FROM DATA CATALOG
DATABASE 'myowndb'
IAM_ROLE 'arn:aws:iam::783152459493:role/RedshiftRole'
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
LOCATION 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1rr8ucy1at3hu/data/';

# Federated query to aurora database

CREATE EXTERNAL SCHEMA federated
FROM POSTGRES
DATABASE 'stocksummary'
URI 'labstack-bbcae2a4-d4fc-4b93-92cd-d6a-auroracluster-9uhp566befqx.cluster-cz6kzcrvvnkz.us-east-1.rds.amazonaws.com'
IAM_ROLE 'arn:aws:iam::783152459493:role/RedshiftRole'
SECRET_ARN 'arn:aws:secretsmanager:us-east-1:783152459493:secret:AuroraSecrets-89fwvd';


UNLOAD ('SELECT * FROM federated.stocks ORDER BY Trade_Date')
TO 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1rr8ucy1at3hu/unload/stocks_' 
IAM_ROLE 'arn:aws:iam::783152459493:role/RedshiftRole'
PARQUET
maxfilesize 5 mb
ALLOWOVERWRITE;

CREATE EXTERNAL TABLE spectrum.unloadstocks(
    Trade_Date VARCHAR(15),
    Ticker VARCHAR(5),
    High DECIMAL(8,2),
    Low DECIMAL(8,2),
    Open_value DECIMAL(8,2),
    Close DECIMAL(8,2),
    Volume DECIMAL(15),
    Adj_Close DECIMAL(8,2)
)
STORED AS PARQUET
LOCATION 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1rr8ucy1at3hu/unload/' ;

SELECT * FROM spectrum.unloadstocks LIMIT 10;


CREATE EXTERNAL SCHEMA myowndb
FROM DATA CATALOG
DATABASE 'myowndb'
IAM_ROLE 'arn:aws:iam::783152459493:role/RedshiftRole'
CREATE EXTERNAL DATABASE IF NOT EXISTS;

CREATE EXTERNAL TABLE myowndb.unloadstocks(
    Trade_Date VARCHAR(15),
    Ticker VARCHAR(5),
    High DECIMAL(8,2),
    Low DECIMAL(8,2),
    Open_value DECIMAL(8,2),
    Close DECIMAL(8,2),
    Volume DECIMAL(15),
    Adj_Close DECIMAL(8,2)
)
STORED AS PARQUET
LOCATION 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1rr8ucy1at3hu/unload/' ;

SELECT * FROM myowndb.unloadstocks LIMIT 10;
```

# Using Redshift Data api

```bash
aws redshift-data execute-statement \
     --database lab  \
     --cluster-identifier redshiftcluster \
     --secret-arn $RedshiftSecretArn \
     --sql "CREATE SCHEMA data_api_demo;" \
     --region $Region

aws redshift-data describe-statement --id '5327b6f2-5d88-4cb5-8796-7a65716aabb5'  # id is the id from the previous command


aws redshift-data execute-statement \
    --database lab \
    --cluster-identifier redshiftcluster \
    --secret-arn $RedshiftSecretArn  \
    --region $Region \
    --sql "CREATE TABLE data_api_demo.stocks_da (
        Trade_Date VARCHAR(15),
        Ticker VARCHAR(5),
        High DECIMAL(8,2),
        Low DECIMAL(8,2),
        Open_value DECIMAL(8,2),
        Close DECIMAL(8,2),
        Volume DECIMAL(15),
        Adj_Close DECIMAL(8,2)
        )"


aws redshift-data execute-statement \
    --database lab \
    --cluster-identifier redshiftcluster \
    --secret-arn $RedshiftSecretArn \
    --region $Region \
    --sql "COPY data_api_demo.stocks_da
          FROM 's3://$DataBucket/data/stock_prices.csv'
          IAM_ROLE '$RedshiftRoleArn'
          DATEFORMAT 'auto'
          IGNOREHEADER 1
          DELIMITER ','
          IGNOREBLANKLINES;"

aws redshift-data execute-statement \
    --database lab \
    --cluster-identifier redshiftcluster \
    --secret-arn $RedshiftSecretArn \
    --region $Region \
    --sql "select ticker, count(*)
          from data_api_demo.stocks_da
          where close > open_value
          and trade_date > '2020-01-01'
          group by ticker
          order by count(*) desc;"


aws redshift-data get-statement-result --id '8e6a7779-c0e6-4f20-8c86-c6fbdedc8e6d'  # id is id from previous command

aws redshift-data get-statement-result --id '8e6a7779-c0e6-4f20-8c86-c6fbdedc8e6d' --output table

select ticker, count(*) from data_api_demo.stocks_da
    where close > open_value
    and trade_date > '2020-01-01'
    group by ticker
    order by count(*) desc;
```

```bash
psql -h $HOST -U $username -d $dbname

