# docker-log-and-fluent-plugin-s3-with-columnify-example

This repository includes the files used on [Docker のログを columnify で Athena (Presto) に特化した Parquet にする](https://abicky.net/2020/08/17/053055/).

## Put nginx logs to S3

First, put `fluentd/fluentd.env` with content like below:

```
AWS_REGION=...
AWS_SECRET_ACCESS_KEY=...
AWS_ACCESS_KEY_ID=...
S3_BUCKET=...
S3_REGION=...
```

and launch the nginx container:

```
docker-compose up --build
```

Next, send some requests to the nginx:

```
curl localhost
curl localhost/not-found
```

Then, you can see the logs except for ones with status code 2XX in stdout, but see all logs in `s3://$S3_BUCKET/logs`.


## Put pseudo docker logs to S3

You can put pseudo docker logs to `s3://$S3_BUCKET/logs` by the following steps.

First, put `generate_logs/fluentd/fluentd.env` with content like below:

```
AWS_REGION=...
AWS_SECRET_ACCESS_KEY=...
AWS_ACCESS_KEY_ID=...
S3_BUCKET=...
S3_REGION=...
```

Then launch containers:

```
cd ./generate_logs
docker-compose up --build
```

After sending all logs, create parquet objects with smaller row group size:

```
./optimize_row_groups.sh
```

## Count logs with status code 2XX with Athena

You can count logs with status code 2XX with Athena easily:

```
./create_tables.sh
./add_partitions.sh <dt> <hour>
./count_200.sh <dt> <hour>
```

Here is an output:

```
% ./count_200.sh 2020-08-24 12
Count logs with status code 200
Executing query...
SELECT
  COUNT(1)
FROM
  test.nginx_parquet
WHERE
  dt = '2020-08-24'
  AND hour = '12'
  AND log LIKE '%HTTP/1.1" 200%'
;


Result:
_col0
9990042

Statistics:
{
  "engine_execution_time_in_millis": 4574,
  "data_scanned_in_bytes": 552599550,
  "total_execution_time_in_millis": 4872,
  "query_queue_time_in_millis": 285,
  "query_planning_time_in_millis": 1487,
  "service_processing_time_in_millis": 13
}

Executing query...
SELECT
  COUNT(1)
FROM
  test.nginx_parquet_optimized
WHERE
  dt = '2020-08-24'
  AND hour = '12'
  AND log LIKE '%HTTP/1.1" 200%'
;


Result:
_col0
9990042

Statistics:
{
  "engine_execution_time_in_millis": 2546,
  "data_scanned_in_bytes": 552599550,
  "total_execution_time_in_millis": 2739,
  "query_queue_time_in_millis": 179,
  "query_planning_time_in_millis": 682,
  "service_processing_time_in_millis": 14
}

Executing query...
SELECT
  COUNT(1)
FROM
  test.nginx_lzo
WHERE
  dt = '2020-08-24'
  AND hour = '12'
  AND log LIKE '%HTTP/1.1" 200%'
;


Result:
_col0
9990042

Statistics:
{
  "engine_execution_time_in_millis": 6944,
  "data_scanned_in_bytes": 756799241,
  "total_execution_time_in_millis": 7119,
  "query_queue_time_in_millis": 146,
  "query_planning_time_in_millis": 627,
  "service_processing_time_in_millis": 29
}

Executing query...
SELECT
  COUNT(1)
FROM
  test.nginx_gz
WHERE
  dt = '2020-08-24'
  AND hour = '12'
  AND log LIKE '%HTTP/1.1" 200%'
;


Result:
_col0
9990042

Statistics:
{
  "engine_execution_time_in_millis": 6870,
  "data_scanned_in_bytes": 363310611,
  "total_execution_time_in_millis": 7058,
  "query_queue_time_in_millis": 172,
  "query_planning_time_in_millis": 686,
  "service_processing_time_in_millis": 16
}


Count logs with status code 200 between 2020-08-24 12:00:00 and 2020-08-24 12:10:00
Executing query...
SELECT
  COUNT(1)
FROM
  test.nginx_parquet
WHERE
  dt = '2020-08-24'
  AND hour = '12'
  AND log_time BETWEEN TIMESTAMP '2020-08-24 12:00:00' AND TIMESTAMP '2020-08-24 12:10:00'
  AND log LIKE '%HTTP/1.1" 200%'
;


Result:
_col0
1664935

Statistics:
{
  "engine_execution_time_in_millis": 5567,
  "data_scanned_in_bytes": 135486504,
  "total_execution_time_in_millis": 5854,
  "query_queue_time_in_millis": 292,
  "query_planning_time_in_millis": 1835
}

Executing query...
SELECT
  COUNT(1)
FROM
  test.nginx_parquet_optimized
WHERE
  dt = '2020-08-24'
  AND hour = '12'
  AND log_time BETWEEN TIMESTAMP '2020-08-24 12:00:00' AND TIMESTAMP '2020-08-24 12:10:00'
  AND log LIKE '%HTTP/1.1" 200%'
;


Result:
_col0
1664935

Statistics:
{
  "engine_execution_time_in_millis": 2460,
  "data_scanned_in_bytes": 109240647,
  "total_execution_time_in_millis": 2595,
  "query_queue_time_in_millis": 127,
  "query_planning_time_in_millis": 693,
  "service_processing_time_in_millis": 8
}

Executing query...
SELECT
  COUNT(1)
FROM
  test.nginx_lzo
WHERE
  dt = '2020-08-24'
  AND hour = '12'
  AND log_time BETWEEN TIMESTAMP '2020-08-24 12:00:00' AND TIMESTAMP '2020-08-24 12:10:00'
  AND log LIKE '%HTTP/1.1" 200%'
;


Result:
_col0
1664935

Statistics:
{
  "engine_execution_time_in_millis": 8370,
  "data_scanned_in_bytes": 756799241,
  "total_execution_time_in_millis": 8731,
  "query_queue_time_in_millis": 298,
  "query_planning_time_in_millis": 1596,
  "service_processing_time_in_millis": 63
}

Executing query...
SELECT
  COUNT(1)
FROM
  test.nginx_gz
WHERE
  dt = '2020-08-24'
  AND hour = '12'
  AND log_time BETWEEN TIMESTAMP '2020-08-24 12:00:00' AND TIMESTAMP '2020-08-24 12:10:00'
  AND log LIKE '%HTTP/1.1" 200%'
;


Result:
_col0
1664935

Statistics:
{
  "engine_execution_time_in_millis": 7059,
  "data_scanned_in_bytes": 363310611,
  "total_execution_time_in_millis": 7190,
  "query_queue_time_in_millis": 129,
  "query_planning_time_in_millis": 750,
  "service_processing_time_in_millis": 2
}

```
