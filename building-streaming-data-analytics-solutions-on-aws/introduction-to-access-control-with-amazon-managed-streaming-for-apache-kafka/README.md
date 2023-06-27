# Introduction to Access Control with Amazon Managed Streaming for Apache Kafka

```bash
cat /opt/kafka_2.12-2.2.1/msk.env
```

```bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/kafka_2.12-2.2.1/bin:/opt/apache-maven-3.8.8/bin:/usr/local/bin/

export MSK_ARN=arn:aws:kafka:us-east-1:783152459493:cluster/MSK-Demo/64f445eb-4c4a-4983-88b0-caf34a2087fa-11

export MSK_BOOTSTRAP="b-1.mskdemo.pg2go1.c11.kafka.us-east-1.amazonaws.com:9094,b-2.mskdemo.pg2go1.c11.kafka.us-east-1.amazonaws.com:9094,b-3.mskdemo.pg2go1.c11.kafka.us-east-1.amazonaws.com:9094"

export MSK_ZOOKEEPER="z-1.mskdemo.pg2go1.c11.kafka.us-east-1.amazonaws.com:2181,z-3.mskdemo.pg2go1.c11.kafka.us-east-1.amazonaws.com:2181,z-2.mskdemo.pg2go1.c11.kafka.us-east-1.amazonaws.com:2181"

export MSKIAM_BOOTSTRAP="b-1.mskdemo.pg2go1.c11.kafka.us-east-1.amazonaws.com:9098,b-2.mskdemo.pg2go1.c11.kafka.us-east-1.amazonaws.com:9098,b-3.mskdemo.pg2go1.c11.kafka.us-east-1.amazonaws.com:9098"

```

To enable IAM authentication in Java app for MSK

```bash
props.put("security.protocol", "SASL_SSL");
props.put("sasl.mechanism", "AWS_MSK_IAM");
props.put("sasl.jaas.config", "software.amazon.msk.auth.iam.IAMLoginModule required;");
props.put("sasl.client.callback.handler.class", "software.amazon.msk.auth.iam.IAMClientCallbackHandler");
```

File: pom.xml

```bash
<dependency>
  <groupId>software.amazon.msk</groupId>
  <artifactId>aws-msk-iam-auth</artifactId>
  <version>1.0.0</version>
</dependency>
```


```bash
source /opt/kafka_2.12-2.2.1/msk.env

# Create a topic
kafka-topics.sh --create --topic ExampleTopic --partitions 5 --replication-factor 3 --bootstrap-server $MSK_BOOTSTRAP  --command-config /opt/client.properties

# List topics

kafka-topics.sh --list --bootstrap-server $MSK_BOOTSTRAP --command-config /opt/client.properties
```

Configuring for iam authentication

```bash
cd /opt/msk-java/

# Build the Java application
mvn package

# Publish to the topic
java -cp target/msk-auth-demo-1.0-SNAPSHOT.jar com.amazonaws.examples.DemoProducer $MSKIAM_BOOTSTRAP ExampleTopic
```

To consume the messag from the topic open a new terminal shell and run the following command

```bash
source /opt/kafka_2.12-2.2.1/msk.env

cd /opt/msk-java/

java -cp target/msk-auth-demo-1.0-SNAPSHOT.jar com.amazonaws.examples.DemoConsumer $MSKIAM_BOOTSTRAP ExampleTopic
```