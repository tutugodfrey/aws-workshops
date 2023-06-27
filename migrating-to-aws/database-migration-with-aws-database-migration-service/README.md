# Database Migration With AWS Database Migration Service

Connect to the source database.

```bash
mysql -u root -pAWSRocksSince2006

GRANT REPLICATION CLIENT ON *.* to 'wordpress-user';

GRANT REPLICATION SLAVE ON *.* to 'wordpress-user';

GRANT SUPER ON *.* to 'wordpress-user';


## Confirm binary logging

select variable_value as "BINARY LOGGING STATUS (log-bin) ::" from performance_schema.global_variables where variable_name='log_bin';

select variable_value as "BINARY LOG FORMATTT (binlog_format) ::" from performance_schema.global_variables where variable_name='binlog_format';

select variable_name, variable_value from performance_schema.global_variables where variable_name='log_bin';

select variable_name, variable_value from performance_schema.global_variables where variable_name='binlog_format';
```

```bash
mysql -u admin -h targetrdsdatabase.ccfcbvh4gljc.us-west-2.rds.amazonaws.com -ppassword1234

RDSEndpoint=targetrdsdatabase.ccfcbvh4gljc.us-west-2.rds.amazonaws.com
mysql -u admin -ppassword1234 -h $RDSEndpoint
show databases;
```

Run the insert query on the source database 

```bash
insert into wp_woocommerce_tax_rates values(1, "NG", "Lagos", 10, "income tax", 2, 0, 1, 10, "order");
insert into wp_woocommerce_tax_rates values(2, "NG", "Delta", 10, "income tax", 2, 0, 1, 10, "order");
```

Run the select query on the target DB 

```bash
select * from wp_woocommerce_tax_rates;
insert into wp_woocommerce_tax_rates values(3, "NG", "Imo", 10, "income tax", 2, 0, 1, 10, "order");
```

Create a user for postgres rds

```bash
CREATE USER "wordpress-user" WITH PASSWORD 'AWSRocksSince2006';
ALTER SCHEMA schema_name OWNER TO wordpress-user;;
```

## Resources

[How to work with native CDC support in AWS DMS](https://aws.amazon.com/blogs/database/aws-dms-now-supports-native-cdc-support/)