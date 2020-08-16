CREATE EXTERNAL TABLE IF NOT EXISTS ${ATHENA_DATABASE}.nginx_lzo (
  `log_time` TIMESTAMP,
  `container_id` STRING,
  `container_name` STRING,
  `source` STRING,
  `log` STRING
)
PARTITIONED BY (dt STRING, hour STRING)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
STORED AS INPUTFORMAT  'com.hadoop.mapred.DeprecatedLzoTextInputFormat'
          OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://${S3_BUCKET}/logs/nginx_lzo/'
TBLPROPERTIES ('has_encrypted_data'='false');
