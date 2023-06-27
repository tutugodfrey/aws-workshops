# Improve Your Architecture With Amazon CloudFront

Control Cache from S3 

Set the header Key `Cache-Control` Value `max-age=10`

Check download load time

```bash
for i in `seq 1 10`; do echo $i; curl -s -o /dev/null --write-out "size_download: %{size_download} // time_total: %{time_total} // time_starttransfer: %{time_starttransfer}\n" http://[s3WebsiteDomain]/test/download.test; done

for i in `seq 1 10`; do echo $i; curl -s -o /dev/null --write-out "size_download: %{size_download} // time_total: %{time_total} // time_starttransfer: %{time_starttransfer}\n" http://http://originbucket-7405.s3-website-us-east-1.amazonaws.com/test/download.test; done

for i in `seq 1 10`; do echo $i; curl -s -o /dev/null --write-out "size_download: %{size_download} // time_total: %{time_total} // time_starttransfer: %{time_starttransfer}\n" http://d29zc17wbspjk9.cloudfront.net//test/download.test; done


for i in `seq 1 10`; do echo $i; curl -s -o /dev/null --write-out "size_download: %{size_download} // time_total: %{time_total} // time_starttransfer: %{time_starttransfer}\n" https://yevexotlqj.execute-api.us-east-1.amazonaws.com/api//echo; done

for i in `seq 1 10`; do echo $i; curl -s -o /dev/null --write-out "size_download: %{size_download} // time_total: %{time_total} // time_starttransfer: %{time_starttransfer}\n" https://d29zc17wbspjk9.cloudfront.net/api/echo; done

curl -s -o /dev/null -w 'size_download: %{size_download}\n' https://originbucket-7405.s3-website-us-east-1.amazonaws.com/test/compress.txt

curl -s -o /dev/null -H 'Accept-Encoding:gzip' -w 'size_download: %{size_download}\n' http://d29zc17wbspjk9.cloudfront.net/test/compress.txt

curl -s -o /dev/null -H 'Accept-Encoding:br' -w 'size_download: %{size_download}\n' http://d29zc17wbspjk9.cloudfront.net/test/compress.txt

curl -v -o /dev/null http://d29zc17wbspjk9.cloudfront.net/api/teststaleobject -H "X-API-KEY: ObPpN18SfC1t0JtvFnwUn2n6zavlnH4q9KYk1Via"

```


S3 Bucket Policy to allow public access

```bash
{
	"Version": "2008-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": "*",
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::originbucket-7405/*"
		}
	]
}
```

Athena Create Table

```bash
CREATE EXTERNAL TABLE IF NOT EXISTS default.cloudfront_logs (
  `date` DATE,
  time STRING,
  location STRING,
  bytes BIGINT,
  request_ip STRING,
  method STRING,
  host STRING,
  uri STRING,
  status INT,
  referrer STRING,
  user_agent STRING,
  query_string STRING,
  cookie STRING,
  result_type STRING,
  request_id STRING,
  host_header STRING,
  request_protocol STRING,
  request_bytes BIGINT,
  time_taken FLOAT,
  xforwarded_for STRING,
  ssl_protocol STRING,
  ssl_cipher STRING,
  response_result_type STRING,
  http_version STRING,
  fle_status STRING,
  fle_encrypted_fields INT,
  c_port INT,
  time_to_first_byte FLOAT,
  x_edge_detailed_result_type STRING,
  sc_content_type STRING,
  sc_content_len BIGINT,
  sc_range_start BIGINT,
  sc_range_end BIGINT
)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
LOCATION 's3://cloudfront-workshop-logbucket-oveg7ht0zaxq/'
TBLPROPERTIES ( 'skip.header.line.count'='2' )
```