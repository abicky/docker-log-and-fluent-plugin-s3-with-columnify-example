#!/bin/bash

cd $(dirname $0)

dt=$1
hour=$2
if [ -z "$dt" ] || [ -z "$hour" ]; then
  echo "usage: $(basename $0) <dt> <hour>"
  exit 1
fi

echo 'Count logs with status code 200'
for table in nginx_parquet nginx_parquet_optimized nginx_lzo nginx_gz; do
  cat <<SQL | ./athena -
SELECT
  COUNT(1)
FROM
  $ATHENA_DATABASE.$table
WHERE
  dt = '$dt'
  AND hour = '$hour'
  AND log LIKE '%HTTP/1.1" 200%'
;
SQL
  echo
done

echo
echo "Count logs with status code 200 between $dt $hour:00:00 and $dt $hour:10:00"
for table in nginx_parquet nginx_parquet_optimized nginx_lzo nginx_gz; do
  cat <<SQL | ./athena -
SELECT
  COUNT(1)
FROM
  $ATHENA_DATABASE.$table
WHERE
  dt = '$dt'
  AND hour = '$hour'
  AND log_time BETWEEN TIMESTAMP '$dt $hour:00:00' AND TIMESTAMP '$dt $hour:10:00'
  AND log LIKE '%HTTP/1.1" 200%'
;
SQL
  echo
done
