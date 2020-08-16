#!/bin/bash

cd $(dirname $0)

dt=$1
hour=$2
if [ -z "$dt" ] || [ -z "$hour" ]; then
  echo "usage: $(basename $0) <dt> <hour>"
  exit 1
fi

for key in $(aws s3 ls --recursive s3://$S3_BUCKET/logs/nginx_msgpack/dt=$dt/hour=$hour | awk '{ print $4 }'); do
  echo "Process $key"
  aws s3 cp s3://$S3_BUCKET/$key .
  gunzip $(basename $key)
  input=$(basename ${key%.gz})
  output=${input%.msgpack}.parquet
  new_key=$(echo $key | sed "s/$input.gz/$output/" | sed 's/nginx_msgpack/nginx_parquet_optimized/')
  columnify \
    -schemaType avro \
    -schemaFile fluentd/docker_log.avsc \
    -recordType msgpack \
    -parquetRowGroupSize 35651584 \
    $input | aws s3 cp - s3://$S3_BUCKET/$new_key
done
