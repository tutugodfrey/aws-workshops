# Load and Query Data in an Amazon Redshift Cluster

Connecting to the Redshift cluster

```bash
export PGPASSWORD=Redshift123
psql -U dbadmin -h redshift-cluster-1.c1haiiakvfha.us-east-1.redshift.amazonaws.com -d dev -p 5439

After Connectng to the redshift database

## Create a table

CREATE TABLE IF NOT EXISTS stocksummary (
        Trade_Date VARCHAR(15),
        Ticker VARCHAR(5),
        High DECIMAL(8,2),
        Low DECIMAL(8,2),
        Open_value DECIMAL(8,2),
        Close DECIMAL(8,2),
        Volume DECIMAL(15),
        Adj_Close DECIMAL(8,2)
        );


## Import Data from s3 to redshift
dev=# COPY stocksummary
dev-# FROM 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-12kn2cxg2mhhx/data/stock_prices.csv'
dev-# iam_role 'arn:aws:iam::285499550393:role/RedshiftAccessRole'
dev-# CSV IGNOREHEADER 1;


# Select query
select * from stocksummary limit 10;
SELECT * FROM stocksummary WHERE Trade_Date LIKE '2020-01-03' ORDER BY Ticker;

# usng the psql prompt enter the following query to find the all time high stock price for each company

select a.ticker, a.trade_date, '$'||a.adj_close as highest_stock_price
from stocksummary a,
  (select ticker, max(adj_close) adj_close
  from stocksummary x
  group by ticker) b
where a.ticker = b.ticker
  and a.adj_close = b.adj_close
order by a.ticker;

```

Challenge - Work with movies Data

```bash
CREATE TABLE IF NOT EXISTS movies  (
        year VARCHAR(4) DEFAULT NULL,
        title VARCHAR(200) DEFAULT NULL,
        directors VARCHAR(35) DEFAULT NULL,
        rating VARCHAR(10) DEFAULT NULL,
        genres_0 VARCHAR(35) DEFAULT NULL,
        genres_1 VARCHAR(35) DEFAULT NULL,
        rank VARCHAR(10) DEFAULT NULL,
        running_time_secs VARCHAR(35) DEFAULT NULL,
        actors_0 VARCHAR(35) DEFAULT NULL,
        actors_1 VARCHAR(35) DEFAULT NULL,
        actors_2 VARCHAR(35) DEFAULT NULL,
        directors_1 VARCHAR(35) DEFAULT NULL,
        directors_2 VARCHAR(35) DEFAULT NULL
);


COPY movies
FROM 's3://labstack-bbcae2a4-d4fc-4b93-92cd-challengebucket-16p3b52lazlmx/data/movies.csv'
iam_role 'arn:aws:iam::005916753752:role/RedshiftAccessRole'
CSV IGNOREHEADER 1;

SELECT title FROM movies WHERE actors_0='Mark Wahlberg' OR actors_1='Mark Wahlberg' OR actors_2='Mark Wahlberg';
```


```bash
COPY stocksummary
FROM 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-5uvkm5rcatba/data/stock_prices.csv'
iam_role 'arn:aws:iam::783152459493:role/RedshiftAccessRole' 
CSV IGNOREHEADER 1;



COPY movies
FROM 's3://labstack-bbcae2a4-d4fc-4b93-92cd-challengebucket-1wsq9s5me1g5j/data/movies.csv'
iam_role 'arn:aws:iam::783152459493:role/RedshiftAccessRole'
CSV IGNOREHEADER 1;

SELECT * FROM STL_LOAD_ERRORS           # When there is error


SELECT title FROM movies WHERE actors_0='Mark Wahlberg' OR actors_1='Mark Wahlberg' OR actors_2='Mark Wahlberg';


COPY stocksummary
FROM 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1t4djvvfmxn4g/data/stock_prices.csv'
iam_role 'arn:aws:iam::005916753752:role/RedshiftAccessRole' 
CSV IGNOREHEADER 1;

COPY movies
FROM 's3://labstack-bbcae2a4-d4fc-4b93-92cd-challengebucket-lybutru5d8li/data/movies.csv'
iam_role 'arn:aws:iam::005916753752:role/RedshiftAccessRole'
CSV IGNOREHEADER 1;
```