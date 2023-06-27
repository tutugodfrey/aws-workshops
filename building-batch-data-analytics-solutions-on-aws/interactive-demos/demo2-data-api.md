## Interactive Demo 2: Connecting your Amazon Redshift cluster using a Jupyter notebook with Data API
In this demo, you connect an Amazon SageMaker Jupyter notebook to the Redshift cluster and run Data API commands in Python. You perform the following activities:

* Create a Redshift table
* Load the stock data from an Amazon Simple Storage Service (Amazon S3) bucket
* Query the data from a Jupyter notebook using Data API

## Prerequisites
This demo requires the following Python modules and custom waiter for the Amazon Redshift Data API to wait for the completed run of the current SQL statement.


```python
# These are libraries required for the demo activities.

import botocore.session as s
from botocore.exceptions import ClientError
import boto3.session
import json
import boto3
import sagemaker
import operator
from botocore.exceptions import WaiterError
from botocore.waiter import WaiterModel
from botocore.waiter import create_waiter_with_client

import pandas as pd
import numpy as np


# Create a custom waiter for the Amazon Redshift Data API to wait for the completed run of the current SQL statement.
waiter_name = 'DataAPIExecution'

delay=2
max_attempts=3

# Configure the waiter settings.
waiter_config = {
  'version': 2,
  'waiters': {
    'DataAPIExecution': {
      'operation': 'DescribeStatement',
      'delay': delay,
      'maxAttempts': max_attempts,
      'acceptors': [
        {
          "matcher": "path",
          "expected": "FINISHED",
          "argument": "Status",
          "state": "success"
        },
        {
          "matcher": "pathAny",
          "expected": ["PICKED","STARTED","SUBMITTED"],
          "argument": "Status",
          "state": "retry"
        },
        {
          "matcher": "pathAny",
          "expected": ["FAILED","ABORTED"],
          "argument": "Status",
          "state": "failure"
        }
      ],
    },
  },
}
```

## Retrieve DB detail secrets from AWS Secrets Manager and establish a connection with the Redshift cluster

You must retrieve the following from AWS Secrets Manager:
* Cluster identifier
* Secrets ARN
* Database name
* Data bucket


```python
secret_name='demolab-secrets' # Replace the secret name with yours.
session = boto3.session.Session()
region = session.region_name

client = session.client(
        service_name='secretsmanager',
        region_name=region
    )

try:
    get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    secret_arn=get_secret_value_response['ARN']

except ClientError as e:
    print("Error retrieving secret. Error: " + e.response['Error']['Message'])
    
else:
    # Depending on whether the secret is a string or binary, one of these fields will be populated.
    if 'SecretString' in get_secret_value_response:
        secret = get_secret_value_response['SecretString']
    else:
        secret = base64.b64decode(get_secret_value_response['SecretBinary'])
            
secret_json = json.loads(secret)

cluster_id = secret_json['dbClusterIdentifier']
db = secret_json['db']
s3_data_path = "s3://{}/data/stock_prices.csv".format(secret_json['dataBucket'])
print("Region: " + region + "\nCluster_id: " + cluster_id + "\nDB: " + db + "\nSecret ARN: " + secret_arn + "\ndata file location: " + s3_data_path)

# Create a Data API client and test it.
bc_session = s.get_session()

session = boto3.Session(
        botocore_session=bc_session,
        region_name=region,
    )

# Set up the Data API client.
client_redshift = session.client("redshift-data")
print("Data API client successfully loaded")

# List all the schemas in the current database `demolab`.
client_redshift.list_schemas(
    Database= db, 
    SecretArn= secret_arn, 
    ClusterIdentifier= cluster_id)["Schemas"]
```

    Region: us-east-1
    Cluster_id: redshiftcluster-wrkdeiwkrlbn
    DB: demolab
    Secret ARN: arn:aws:secretsmanager:us-east-1:005916753752:secret:demolab-secrets-oykTgh
    data file location: s3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1l1h1p1onr7i1/data/stock_prices.csv
    Data API client successfully loaded





    ['catalog_history',
     'information_schema',
     'pg_automv',
     'pg_catalog',
     'pg_internal',
     'public']



## Create a table schema and table
Using Data API, you create a `stocksummary` schema and `stocks` table.


```python
# First, set the waiter when running a query to help you wait for the response.
waiter_model = WaiterModel(waiter_config)
custom_waiter = create_waiter_with_client(waiter_name, waiter_model, client_redshift)

# Script for schema create.
query_str = "create schema if not exists stocksummary;"

res = client_redshift.execute_statement(Database= db, SecretArn= secret_arn, Sql= query_str, ClusterIdentifier= cluster_id)
id=res["Id"]

# Waiter in try block and wait for DATA API to return.
try:
    custom_waiter.wait(Id=id)   
    print("Schema creation is successful.") 
except WaiterError as e:
    print (e)
    
desc=client_redshift.describe_statement(Id=id)
print("Status: " + desc["Status"] + ". Run time: %d milliseconds" %float(desc["Duration"]/pow(10,6)))

query_str = 'CREATE TABLE IF NOT EXISTS stocksummary.stocks (\
            Trade_Date VARCHAR(15) NOT NULL,\
            Ticker VARCHAR(5) NOT NULL,\
            High DECIMAL(8,2),\
            Low DECIMAL(8,2),\
            Open_value DECIMAL(8,2),\
            Close DECIMAL(8,1),\
            Volume DECIMAL(15),\
            Adj_Close DECIMAL(8,2) NOT NULL )\
            sortkey (Trade_Date);'

res = client_redshift.execute_statement(Database= db, SecretArn= secret_arn, Sql= query_str, ClusterIdentifier= cluster_id)
id=res["Id"]

try:
    custom_waiter.wait(Id=id)
    print("Table creation is successful.")
except WaiterError as e:
    print (e)
    
desc=client_redshift.describe_statement(Id=id)
print("Status: " + desc["Status"] + ". Run time: %d milliseconds" %float(desc["Duration"]/pow(10,6)))

```

    Schema creation is successful.
    Status: FINISHED. Run time: 58 milliseconds
    Table creation is successful.
    Status: FINISHED. Run time: 53 milliseconds


## Loading data
Now, you load data from Amazon S3 to the `stocks` table.


```python
redshift_iam_role = sagemaker.get_execution_role() 
print("IAM Role: " + redshift_iam_role)

# Set the 'delay' attribute of the waiter to 10 seconds for long-running COPY statement.
waiter_config["waiters"]["DataAPIExecution"]["delay"] = 10
waiter_model = WaiterModel(waiter_config)
custom_waiter = create_waiter_with_client(waiter_name, waiter_model, client_redshift)

query = "COPY stocksummary.stocks FROM '" + s3_data_path + "' IAM_ROLE '" + redshift_iam_role + "' CSV IGNOREHEADER 1;"

print("COPY query: " + query)
# Run COPY statements in parallel.
resp = client_redshift.execute_statement(Database= db, SecretArn= secret_arn, Sql= query, ClusterIdentifier= cluster_id)

print("Redshift COPY started ...")

id = resp["Id"]
print("\nID: " + id)

# Waiter in try block and wait for DATA API to return.
try:
    custom_waiter.wait(Id=id)
    print("Done waiting to finish Data API for the COPY statement.")
except WaiterError as e:
    print (e)

desc=client_redshift.describe_statement(Id=id)
print("[COPY] Status: " + desc["Status"] + ". Run time: %d milliseconds" %float(desc["Duration"]/pow(10,6)))

# Reset the 'delay' attribute of the waiter to 5 seconds for long-running COPY statement.
waiter_config["waiters"]["DataAPIExecution"]["delay"] = 5
waiter_model = WaiterModel(waiter_config)
custom_waiter = create_waiter_with_client(waiter_name, waiter_model, client_redshift)
```

    IAM Role: arn:aws:iam::005916753752:role/LabStack-bbcae2a4-d4fc-4b93-RedshiftSagemakerRole-1F2VN18WY5NFE
    COPY query: COPY stocksummary.stocks FROM 's3://labstack-bbcae2a4-d4fc-4b93-92cd-d6a0b-databucket-1l1h1p1onr7i1/data/stock_prices.csv' IAM_ROLE 'arn:aws:iam::005916753752:role/LabStack-bbcae2a4-d4fc-4b93-RedshiftSagemakerRole-1F2VN18WY5NFE' CSV IGNOREHEADER 1;
    Redshift COPY started ...
    
    ID: b264f6af-96d7-4df7-8e9f-80b2a56042ae
    Done waiting to finish Data API for the COPY statement.
    [COPY] Status: FINISHED. Run time: 2237 milliseconds


## Querying data (in-place analytics)

You can use Amazon Redshift Data API to perform in-place data analytics.


```python
#1. Number of stock records in the dataset.

query_str = "select  count(*) as record_count from stocksummary.stocks"

res = client_redshift.execute_statement(Database= db, SecretArn= secret_arn, Sql= query_str, ClusterIdentifier= cluster_id)
print("Redshift Data API execution  started ...")
id = res["Id"]

# Waiter in try block and wait for DATA API to return.
try:
    custom_waiter.wait(Id=id)
    print("Done waiting to finish Data API.")
except WaiterError as e:
    print (e)
    
output=client_redshift.get_statement_result(Id=id)
nrows=output["TotalNumRows"]
ncols=len(output["ColumnMetadata"])
resultrows=output["Records"]

col_labels=[]
for i in range(ncols): col_labels.append(output["ColumnMetadata"][i]['label'])
                                              
# Load the results into a dataframe.
df = pd.DataFrame(np.array(resultrows), columns=col_labels)

# Reformatting the results before display.
for i in range(ncols): 
    df[col_labels[i]]=df[col_labels[i]].apply(operator.itemgetter('longValue'))

df
```

    Redshift Data API execution  started ...
    Done waiting to finish Data API.





<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>record_count</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>108230</td>
    </tr>
  </tbody>
</table>
</div>




```python
#2. Find out top 10 high stock prices for dis (Disney) ticker.

query_str = "select * from stocksummary.stocks \
where ticker = 'dis' \
order by adj_close desc limit 10;"

res = client_redshift.execute_statement(Database= db, SecretArn= secret_arn, Sql= query_str, ClusterIdentifier= cluster_id)
print("Redshift Data API execution  started ...")
id = res["Id"]

# Waiter in try block and wait for DATA API to return.
try:
    custom_waiter.wait(Id=id)
    print("Done waiting to finish Data API.")
except WaiterError as e:
    print (e)
    
output=client_redshift.get_statement_result(Id=id)
nrows=output["TotalNumRows"]
ncols=len(output["ColumnMetadata"])
resultrows=output["Records"]

col_labels=[]
for i in range(ncols): col_labels.append(output["ColumnMetadata"][i]['label'])
                                              
# Load the results into a dataframe.
df = pd.DataFrame(np.array(resultrows), columns=col_labels)

# Reformatting the results before display.
for i in range(ncols): 
    df[col_labels[i]]=df[col_labels[i]].apply(operator.itemgetter('stringValue'))

df
```

    Redshift Data API execution  started ...
    Done waiting to finish Data API.





<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>trade_date</th>
      <th>ticker</th>
      <th>high</th>
      <th>low</th>
      <th>open_value</th>
      <th>close</th>
      <th>volume</th>
      <th>adj_close</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2021-03-08</td>
      <td>dis</td>
      <td>203.02</td>
      <td>193.78</td>
      <td>197.30</td>
      <td>201.9</td>
      <td>25093200</td>
      <td>201.91</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2021-02-24</td>
      <td>dis</td>
      <td>200.60</td>
      <td>195.33</td>
      <td>197.58</td>
      <td>197.5</td>
      <td>16205900</td>
      <td>197.50</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2021-03-12</td>
      <td>dis</td>
      <td>198.41</td>
      <td>195.17</td>
      <td>196.52</td>
      <td>197.1</td>
      <td>13249100</td>
      <td>197.16</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2021-02-23</td>
      <td>dis</td>
      <td>198.94</td>
      <td>188.66</td>
      <td>193.58</td>
      <td>197.0</td>
      <td>23191400</td>
      <td>197.08</td>
    </tr>
    <tr>
      <th>4</th>
      <td>2021-03-11</td>
      <td>dis</td>
      <td>199.05</td>
      <td>195.39</td>
      <td>197.38</td>
      <td>196.7</td>
      <td>11933900</td>
      <td>196.75</td>
    </tr>
    <tr>
      <th>5</th>
      <td>2021-03-15</td>
      <td>dis</td>
      <td>198.53</td>
      <td>194.80</td>
      <td>198.53</td>
      <td>196.7</td>
      <td>10311400</td>
      <td>196.75</td>
    </tr>
    <tr>
      <th>6</th>
      <td>2021-03-17</td>
      <td>dis</td>
      <td>196.19</td>
      <td>191.77</td>
      <td>193.44</td>
      <td>195.2</td>
      <td>14418700</td>
      <td>195.24</td>
    </tr>
    <tr>
      <th>7</th>
      <td>2021-03-10</td>
      <td>dis</td>
      <td>198.80</td>
      <td>194.67</td>
      <td>197.30</td>
      <td>195.0</td>
      <td>13662100</td>
      <td>195.05</td>
    </tr>
    <tr>
      <th>8</th>
      <td>2021-03-01</td>
      <td>dis</td>
      <td>196.89</td>
      <td>191.38</td>
      <td>193.22</td>
      <td>194.9</td>
      <td>10709900</td>
      <td>194.97</td>
    </tr>
    <tr>
      <th>9</th>
      <td>2021-03-09</td>
      <td>dis</td>
      <td>201.69</td>
      <td>194.36</td>
      <td>200.19</td>
      <td>194.5</td>
      <td>23331000</td>
      <td>194.50</td>
    </tr>
  </tbody>
</table>
</div>



## Challenge activity

Find the 10 lowest trading volume days for ticker tsla (Tesla)


```python
# Write your code here and run the cell.
# Hint - Except for the query, the rest of the code is the same as the previous cell.

```

## Demo 2 Complete
