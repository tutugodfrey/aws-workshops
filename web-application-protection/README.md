# Web Application Protection

Lab Guide
[]([Workshop guide of Event](https://catalog.us-east-1.prod.workshops.aws/workshops/81e94a4b-b47f-4acc-a284-914c4514d50f/en-US/1-gettingstarted/1-workshop-studio))


```bash
(?i)\.(jpe?g|gif|png|svg|ico|css|js|woff2?)$   # Regex rule for static content of website. use to create regex rule in aws waf

^0*(?:[1-9][0-9]?|100)$     # Regex to match number between 1 - 100
```

Athena Query for WAF LOG

```bash
WITH DATASET AS (SELECT header FROM waf_access_logs CROSS JOIN UNNEST(httprequest.headers) AS t(header) WHERE day >= '2021/01/01' AND day < '2031/12/31') SELECT header.name,count(*) headerNameCount FROM DATASET GROUP BY header.name ORDER BY headerNameCount DESC


SELECT COUNT(*) AS
count,
terminatingruleid,
httprequest.clientip,
httprequest.uri
FROM waf_access_logs
WHERE action='BLOCK'
GROUP BY terminatingruleid, httprequest.clientip, httprequest.uri
ORDER BY count DESC
LIMIT 100;


SELECT COUNT(*) AS
count,
terminatingruleid,
httprequest.clientip,
httprequest.uri
FROM waf_access_logs
WHERE action='BLOCK' AND httprequest.uri='/api/listproducts.php'
GROUP BY terminatingruleid, httprequest.clientip, httprequest.uri
ORDER BY count DESC
LIMIT 100;


SELECT COUNT(*) AS
count,
action,
httprequest.clientip,
httprequest.uri
FROM waf_access_logs
WHERE terminatingruleid='path-block'
GROUP BY action, httprequest.clientip, httprequest.uri
ORDER BY count DESC
LIMIT 100;

SELECT COUNT(*) AS
count,
action,
httprequest.clientip,
httprequest.uri
FROM waf_access_logs
WHERE terminatingruleid='AWS-AWSManagedRulesCommonRuleSet'
GROUP BY action, httprequest.clientip, httprequest.uri
ORDER BY count DESC
LIMIT 100;


SELECT COUNT(*) AS
count,
action,
httprequest.clientip,
httprequest.uri
FROM waf_access_logs
WHERE terminatingruleid='zyborg-block'
GROUP BY action, httprequest.clientip, httprequest.uri
ORDER BY count DESC
LIMIT 100;


## Mystery HEAD

WITH DATASET AS (SELECT header FROM waf_access_logs CROSS JOIN UNNEST(httprequest.headers) AS t(header) WHERE day >= '2021/01/01' AND day < '2031/12/31') SELECT DISTINCT header.name header_name, header.value encoded_header_value FROM DATASET WHERE LOWER(header.name)='mysteryhint'

WITH DATASET AS (SELECT header FROM waf_access_logs CROSS JOIN UNNEST(httprequest.headers) AS t(header) WHERE day >= '2021/01/01' AND day < '2031/12/31') SELECT DISTINCT header.name header_name, header.value encoded_header_value FROM DATASET WHERE LOWER(header.name)='mysteryhint'

SELECT from_utf8(from_base64('U2VjdXJpdHkgaXMgam9iIHplcm8h')) decoded_value           # decode an encoded text

SELECT from_utf8(from_base64('U2VjdXJpdHkgaXMgam9iIHplcm8h')) decoded_value

```

Use Core rule set and SQL Database rule group for blocking common attacks
