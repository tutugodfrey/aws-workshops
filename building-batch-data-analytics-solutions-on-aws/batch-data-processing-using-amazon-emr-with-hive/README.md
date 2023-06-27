# Batch Data Processing using Amazon EMR with Hive

## Connect to EMR Cluster

```bash
export ID=$(aws emr list-clusters | jq '.Clusters[0].Id' | tr -d '"')   # Get Cluster ID
export HOST=$(aws emr describe-cluster --cluster-id $ID| jq '.Cluster.MasterPublicDnsName' | tr -d '"')  # Use the cluster id to get the public dns of the cluster
ssh -i ~/EMRKey.pem hadoop@$HOST          # Connect to the cluster
```

After connecting to the EMR Cluster Master node, run the following commands

```bash
sudo chown hadoop -R /var/log/hive
mkdir /var/log/hive/user/hadoop
hive            # Connect to the hive command line interface
```



```bash
CREATE TABLE stockprice  (
`Trade_Date` string,
`Ticker` string,
`High` double,
`Low` double,
`Open` double,
`Close` double,
`Volume` double,
`Adj_Close` double 
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS
INPUTFORMAT
  'com.amazonaws.emr.s3select.hive.S3SelectableTextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://databucket-us-west-2-267727396/data/'
TBLPROPERTIES (
  "s3select.format" = "csv",
  "s3select.headerInfo" = "ignore",
  "skip.header.line.count"="1"
);
```

```bash
CREATE TABLE movies  (
`year` int,
`title` string,
`directors_0` string,
`rating` string,
`genres_0` string,
`genres_1` string,
`rank` string,
`running_time_secs` string,
`actors_0` string,
`actors_1` string,
`actors_2` string,
`directors_1` string,
`directors_2` string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS
INPUTFORMAT
  'com.amazonaws.emr.s3select.hive.S3SelectableTextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://challengebucket-us-west-2-267727396/data/'
TBLPROPERTIES (
  "s3select.format" = "csv",
  "s3select.headerInfo" = "ignore",
  "skip.header.line.count"="1"
);
```

```bash
COPY stocksummary
FROM 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-123mr85n8urwu/data/stock_prices.csv'
iam_role 'arn:aws:iam::033155433876:role/RedshiftAccessRole' 
CSV IGNOREHEADER 1;

COPY movies
FROM 's3://labstack-bbcae2a4-d4fc-4b93-92cd-challengebucket-buoy5fykv131/data/movies.csv'
iam_role 'arn:aws:iam::033155433876:role/RedshiftAccessRole'  
CSV IGNOREHEADER 1;


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
LOCATION 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-6yjfdvsz7utc/data/';

producer namespace 3c98f985-d46c-4f1e-8818-a78ee450a715
consumer namespace ca1b9bfd-bbd2-4185-861d-33b983d6cf16
```

Rerun the lab

```bash
CREATE TABLE stockprice  (
`Trade_Date` string,
`Ticker` string,
`High` double,
`Low` double,
`Open` double,
`Close` double,
`Volume` double,
`Adj_Close` double 
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS
INPUTFORMAT
  'com.amazonaws.emr.s3select.hive.S3SelectableTextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://databucket-us-east-1-593747978/data/'
TBLPROPERTIES (
  "s3select.format" = "csv",
  "s3select.headerInfo" = "ignore",
  "skip.header.line.count"="1"
);
```

```bash
show tables;
```
### Output

OK
stockprice


```bash
select * from stockprice limit 10;
```

```bash
SET s3select.filter=true
SELECT * FROM stockprice WHERE `Trade_Date` LIKE '2020-01-03' ORDER BY `Ticker`;
```

Challenge 

```bash
CREATE TABLE movies  (
`year` int,
`title` string,
`directors_0` string,
`rating` string,
`genres_0` string,
`genres_1` string,
`rank` string,
`running_time_secs` string,
`actors_0` string,
`actors_1` string,
`actors_2` string,
`directors_1` string,
`directors_2` string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS
INPUTFORMAT
  'com.amazonaws.emr.s3select.hive.S3SelectableTextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://challengebucket-us-east-1-593747978/data/'
TBLPROPERTIES (
  "s3select.format" = "csv",
  "s3select.headerInfo" = "ignore",
  "skip.header.line.count"="1"
);
```

```bash
SELECT COUNT(title) FROM movies WHERE actors_0='Tom Hanks' OR actors_1='Tom Hanks' OR actors_2='Tom Hanks';

SELECT title, actors_0, actors_1, actors_2 FROM movies WHERE actors_0='Tom Hanks' OR actors_1='Tom Hanks' OR actors_2='Tom Hanks';
```


CREATE TABLE stockprice  (
`Trade_Date` string,
`Ticker` string,
`High` double,
`Low` double,
`Open` double,
`Close` double,
`Volume` double,
`Adj_Close` double 
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS
INPUTFORMAT
  'com.amazonaws.emr.s3select.hive.S3SelectableTextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://databucket-us-east-1-162079589/data/'
TBLPROPERTIES (
  "s3select.format" = "csv",
  "s3select.headerInfo" = "ignore",
  "skip.header.line.count"="1"
);

CREATE TABLE movies  (
`year` int,
`title` string,
`directors_0` string,
`rating` string,
`genres_0` string,
`genres_1` string,
`rank` string,
`running_time_secs` string,
`actors_0` string,
`actors_1` string,
`actors_2` string,
`directors_1` string,
`directors_2` string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS
INPUTFORMAT
  'com.amazonaws.emr.s3select.hive.S3SelectableTextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://databucket-us-east-1-162079589/data/'
TBLPROPERTIES (
  "s3select.format" = "csv",
  "s3select.headerInfo" = "ignore",
  "skip.header.line.count"="1"
);
