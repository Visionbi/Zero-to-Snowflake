# Zero-to-Snowflake
Get started scripts with Snowflake - Build for the Cloud Data Warehouse

## Create A new Database
Create database snowdemo;

Use database snowdemo;

## Create Schema for the Source Data
Create schema ODS;

create or replace TABLE ODS.ODS_EVENTS 
cluster by LINEAR(CREATED)(
	UPDATED TIMESTAMP_NTZ(9),
	RESOURCEOWNERID STRING,
	CREATED TIMESTAMP_NTZ(9),
	RESOURCETYPE STRING,
	RESOURCEID STRING,
	EXTRADATA STRING,
	APPVERSION STRING,
	PLATFORM STRING,
	MODIFIEDBY NUMBER(38,0),
	LOCATION STRING,
	MAPINUSE STRING,
	MAIL STRING,
	_ID STRING,
	TYPE STRING
)COMMENT='Created for Zero to Snowflake'
;
## Create warehouse using the UI
Use warehouse DEMO_WH;

copy into ODS.ODS_EVENTS
from s3://snowflake-visionbi-demo/sample_data/events/
credentials = (AWS_KEY_ID='...' 
               AWS_SECRET_KEY='...')
FILE_FORMAT= (type=CSV
              ,NULL_IF = ('NULL','<NULL>','None','<None>')
             )
ON_ERROR=CONTINUE;

```sql
select *
From ODS.ODS_EVENTS
Limit 10;
```

create or replace TABLE ODS.ODS_EVENTS_PAR
(json_data variant)
COMMENT='Create for Zero to Snowflake - with parquet'
;
Show tables;

copy into ODS.ODS_EVENTS_PAR
from s3://snowflake-visionbi-demo/sample_data/events_par/
credentials = (AWS_KEY_ID='...' 
               AWS_SECRET_KEY='...')
FILE_FORMAT = (type=PARQUET)
ON_ERROR=CONTINUE;



select *
From ODS.ODS_EVENTS_PAR
Limit 10;

select  JSON_DATA:APPVERSION APPVERSION_PLAIN,
        JSON_DATA:APPVERSION::STRING APPVERSION,
        JSON_DATA:CREATED::DATETIME CREATED,
        JSON_DATA:NO_COLUMN EMPTY
From ODS.ODS_EVENTS_PAR
Limit 10;


//Export to PARQUET
copy into s3://snowflake-visionbi-demo/sample_data/events_par_export/
from ilan_demo.ODS.ODS_USER_EVENTS
credentials = (AWS_KEY_ID='...' 
               AWS_SECRET_KEY='...')
FILE_FORMAT = (type=PARQUET)
OVERWRITE=TRUE
HEADER = TRUE;






