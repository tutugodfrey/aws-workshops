# Interactive Demo

Screenshot to follow the labs is in screnshots directory


Connect to EMR Cluster

```bash
export ID=$(aws emr list-clusters | jq '.Clusters[0].Id' | tr -d '"')
export HOST=$(aws emr describe-cluster --cluster-id $ID | jq '.Cluster.MasterPublicDnsName' | tr -d '"')
ssh -i EMRKey.pem hadoop@$HOST
```

Get s3 databucket and connect to spark shell

```bash
export bucket=$(aws s3api list-buckets --query 'Buckets[].Name' |  grep databucket | tr -d ' ' | tr -d '"' | tr -d ',')
spark-shell
```

One in the Spark shell prompt

```bash
var bucket = System.getenv("bucket")
val s3_loc = "s3://"+bucket+"/data/stock_prices.csv"
val df = spark.read.option("header", "true").option("inferSchema", "true").csv(s3_loc)
df.printSchema()
df.show()    // df.show also work
df.show(40)
df.groupBy("Ticker").agg(max("Close")).sort("Ticker").show()
```

```bash
scala> df.printSchema()
root
 |-- Trade_Date: string (nullable = true)
 |-- Ticker: string (nullable = true)
 |-- High: double (nullable = true)
 |-- Low: double (nullable = true)
 |-- Open: double (nullable = true)
 |-- Close: double (nullable = true)
 |-- Volume: double (nullable = true)
 |-- Adj_Close: double (nullable = true)
```

```bash
scala> df.groupBy("Ticker").agg(max("Close")).sort("Ticker").show()
+------+------------------+
|Ticker|        max(Close)|
+------+------------------+
|  aapl|136.69000244140625|
|  amzn| 3531.449951171875|
|    ge| 13.15999984741211|
|     m|18.100000381469727|
|  msft|231.64999389648438|
|    sq| 241.5800018310547|
|  tsla| 705.6699829101562|
+------+------------------+
```


Working with EMRFS

```bash
export bucket=$(aws s3api list-buckets --query 'Buckets[].Name' |  grep databucket | tr -d ' ' | tr -d '"' | tr -d ',')
echo 'This is a practice lab!' > outputFile.txt
hadoop fs -put outputFile.txt s3://${bucket}/
aws s3 cp s3://${bucket}/outputFile.txt encryptedOutputFile.txt
```

The file send to s3 is encrypted (encryptedOutputFile.txt)

```bash
cat encryptedOutputFile.txt
```

Output 

```bash
`"��wyk��ő�-=��
               @HՍ��
```


```bash
hadoop fs -cat s3://${bucket}/outputFile.txt
```

Output

```bash
This is a practice lab!
```


Connect to Hive

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
LOCATION 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1779ar95tyaw0/data/'
TBLPROPERTIES (
  "s3select.format" = "csv",
  "s3select.headerInfo" = "ignore",
  "skip.header.line.count"="1"
);

show tables;

SELECT * FROM stockprice WHERE `Trade_Date` LIKE '2020-01-03' ORDER BY `Ticker`;
```


```bash
explain select a.ticker, a.trade_date, '$'||a.adj_close as highest_stock_price
from stocksummary.stocks a,
  (select ticker, max(adj_close) adj_close
  from stocksummary.stocks x
  group by ticker) b
where a.ticker = b.ticker
  and a.adj_close = b.adj_close
order by a.ticker;

select a.ticker, a.trade_date, '$'||a.adj_close as highest_stock_price
from stocksummary.stocks a,
  (select ticker, max(adj_close) adj_close
  from stocksummary.stocks x
  group by ticker) b
where a.ticker = b.ticker
  and a.adj_close = b.adj_close
order by a.ticker;
```