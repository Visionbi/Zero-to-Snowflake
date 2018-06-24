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
-30 Seconds on a Large WH.

*The folder orders_csv will be created automatically
**Make sure to add the / at the end in order to save the data in a new folder. Otherwise it will be a prefix of the output files.

### Sample JSON
Download Weather.DAILY_14_TOTAL table into S3 in CSV format:

```sql
copy into s3://<Bucket_Name>/Snowdemo/sample_data/orders_csv/
from  Snowflake_Sample_Data.TPCH_SF1000.ORDERS
credentials = (AWS_KEY_ID='...' 
               AWS_SECRET_KEY='...')
FILE_FORMAT = (type=CSV)
OVERWRITE=TRUE;
```
-1:40 Minutes on Large WH ()


**REMEMBER TO DELETE THE FOLDERS WHEN YOU COMPLETE THE DEMO TO AVOID S3 CHARGES
