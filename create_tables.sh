#!/bin/bash

cd $(dirname $0)

./athena "CREATE DATABASE IF NOT EXISTS $ATHENA_DATABASE"

for file in ./tables/*.sql; do
  sed "s/\${S3_BUCKET}/$S3_BUCKET/" $file | sed "s/\${ATHENA_DATABASE}/$ATHENA_DATABASE/" | ./athena -
  echo
done
