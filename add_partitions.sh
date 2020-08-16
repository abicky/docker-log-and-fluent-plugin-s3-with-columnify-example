#!/bin/bash

cd $(dirname $0)

dt=$1
hour=$2
if [ -z "$dt" ] || [ -z "$hour" ]; then
  echo "usage: $(basename $0) <dt> <hour>"
  exit 1
fi

for file in ./tables/*.sql; do
  table=$(basename ${file%.sql})
  cat <<SQL | ./athena -
ALTER TABLE $ATHENA_DATABASE.$table ADD IF NOT EXISTS
  PARTITION (dt='$dt', hour='$hour') LOCATION 's3://${S3_BUCKET}/logs/$table/dt=$dt/hour=$hour'
SQL
  echo
done
