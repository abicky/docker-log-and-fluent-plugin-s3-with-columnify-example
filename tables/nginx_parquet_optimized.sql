CREATE EXTERNAL TABLE IF NOT EXISTS ${ATHENA_DATABASE}.nginx_parquet_optimized (
  `log_time` TIMESTAMP,
  `container_id` STRING,
  `container_name` STRING,
  `source` STRING,
  `log` STRING
)
PARTITIONED BY (dt STRING, hour STRING)
STORED AS PARQUET
LOCATION 's3://${S3_BUCKET}/logs/nginx_parquet_optimized/'
TBLPROPERTIES ('has_encrypted_data'='false');
