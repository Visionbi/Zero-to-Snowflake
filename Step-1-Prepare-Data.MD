## Create A new Bucket on S3
1. Create a new bucket
2. Create the following folders Snowdemo/source_data

## Download data from Snowflake Sample Data
The database Snowflake_Sample_Data has different great datasets to play with.
We've selected 2 different sources: Weather Data (Json Format) and Orders Data (CSV Format)
Follow the next steps to download the data into you S3 for the following steps in the demo.

### Sample CSV
Download TPCH_SF1000.ORDERS table into S3 in CSV format:


```sql
copy into s3://<Bucket_Name>/Snowdemo/sample_data/orders_csv/
from  Snowflake_Sample_Data.TPCH_SF1000.ORDERS
credentials = (AWS_KEY_ID='...' 
               AWS_SECRET_KEY='...')
FILE_FORMAT = (type=CSV)
OVERWRITE=TRUE;
```
-(30 Seconds on a Large WH)

*The folder orders_csv will be created automatically
**Make sure to add the / at the end in order to save the data in a new folder. Otherwise it will be a prefix of the output files.

### Sample JSON
Download Weather.DAILY_14_TOTAL table into S3 in JSON format:

In this case we will use "Select V From ..." when V is the Json column in the table. 
You can query the source table to see the json data:
```sql
Select *
From Snowflake_Sample_Data.Weather.DAILY_14_TOTAL
Limit 100;
```

Download:
```sql
copy into s3://<Bucket_Name>/Snowdemo/sample_data/weather_json/
from (Select V From Snowflake_Sample_Data.Weather.DAILY_14_TOTAL)
credentials = (AWS_KEY_ID='...' 
               AWS_SECRET_KEY='...')
FILE_FORMAT = (type=JSON)
OVERWRITE=TRUE;
```
-(1:40 Minutes on Large WH)


### Sample Parquet
Download Weather.DAILY_14_TOTAL table into S3 in PARQUET format. This COPY\UNLOAD option is very powerfull when you need to migrate data from Json to Parquet.:

In this case we will use "Select V From ..." when V is the Json column in the table. 
You can query the source table to see the json data:
```sql
Select *
From Snowflake_Sample_Data.Weather.DAILY_14_TOTAL
Limit 100;
```

Download:
```sql
copy into s3://<Bucket_Name>/Snowdemo/sample_data/weather_json/
from (Select V From Snowflake_Sample_Data.Weather.DAILY_14_TOTAL)
credentials = (AWS_KEY_ID='...' 
               AWS_SECRET_KEY='...')
FILE_FORMAT = (type=PARQUET)
OVERWRITE=TRUE;
```
-(1:40 Minutes on Large WH | 35,653,339 Rows | 35.5 Gb )


**REMEMBER TO DELETE THE FOLDERS WHEN YOU COMPLETE THE DEMO TO AVOID S3 CHARGES
