# Prepare Database 
## Create A new Database
```sql
Create database snowdemo;

Use database snowdemo;
```

## Create Schema for the Source Data
```sql
Create schema ODS;
```

# Load CSV
In this example we will load a CSV file. There are many parameters that can be used depend on your data and use case. It is very easy to find all options on Snowflake documentation on google.

## Load the CSV Sample data
Use the CSV sample data we prepared on Step 0.
In order to load a CSV table you'll first need to create the tables with the relevant columns.
The loading is based on the order of the columns. 
To get the updated create table run this query on the Snowflake Sample Data database (In Case it was changed since we copied it)


```sql
Use database Snowflake_Sample_Data;
select get_ddl('table','TPCH_SF100.ORDERS');
```
*Copy the Create command and execute it on our demo database.

```sql
Use database snowdemo;
create or replace TABLE ODS.ODS_ORDERS (
	O_ORDERKEY NUMBER(38,0) NOT NULL,
	O_CUSTKEY NUMBER(38,0) NOT NULL,
	O_ORDERSTATUS VARCHAR(1) NOT NULL,
	O_TOTALPRICE NUMBER(12,2) NOT NULL,
	O_ORDERDATE DATE NOT NULL,
	O_ORDERPRIORITY VARCHAR(15) NOT NULL,
	O_CLERK VARCHAR(15) NOT NULL,
	O_SHIPPRIORITY NUMBER(38,0) NOT NULL,
	O_COMMENT VARCHAR(79) NOT NULL
)COMMENT='Created for Zero to Snowflake'
;
```

## Copy Data from S3
* Create warehouse using the UI
```sql
Use warehouse DEMO_WH;

copy into ODS.ODS_ORDERS
from s3://<bucket_name>/Snowdemo/sample_data/orders_csv/
credentials = (AWS_KEY_ID='...' 
               AWS_SECRET_KEY='...')
FILE_FORMAT= (type=CSV
              ,NULL_IF = ('NULL','<NULL>','None','<None>')
             )
ON_ERROR=CONTINUE;
```

```sql
select *
From ODS.ODS_ORDERS
Limit 10;
```

# Load Semi-Structured Data
The following example will load a Parquet data. The exact same commands and method will be used for Json data. 
More options can be used on the copy command and it is very easy to find them on Snowflake documentation on google.
Loading Json \ Semi-structured data into a structured table is done in 2 steps. First you'll load the data into a single column table (varient column) and then using an Insert into command.
Please notice that the Json data is indexed and saved in an optimized way, so you can consider to keep it in it's original format and extract only when data is required.

## Load Parquet Files

### Create a table with a single variant column 
```sql
Use database Snowdemo;
create or replace TABLE ODS.ODS_WEATHER_DATA
(json_data variant)
COMMENT='Create for Zero to Snowflake - with parquet'
;
Show tables;
```

### Load Data
```sql
copy into ODS.ODS_WEATHER_DATA
from s3://<bucket_name>/Snowdemo/sample_data/weather_json/
credentials = (AWS_KEY_ID='...' 
               AWS_SECRET_KEY='...')
//FILE_FORMAT = (type=PARQUET)
FILE_FORMAT = (type=JSON)
ON_ERROR=CONTINUE;

select *
From ODS.ODS_WEATHER_DATA
Limit 10;
```


## Load Data Using Stage
To avoid sharing and using the access and secret key on each query, you can create a STAGE once, and then execute the copy commands from that STAGE
###Create STAGE
```sql
create or replace STAGE SNOWSTAGE
    url='s3://snowflake-visionbi-demo/sample_data'
    credentials = (AWS_KEY_ID='...' 
                   AWS_SECRET_KEY='...' )
    FILE_FORMAT = (type=PARQUET);
```
###Load From Stage
```sql
create or replace table ODS.events_par_stage (json_data  variant);

copy into ODS.events_par_stage
from     @SNOWSTAGE/events_par;
```


### Quering Semi-Structure data
Use <column-name>:<attribute> to query the data
	
```sql
select JSON_DATA:city.name::string
From ODS.ODS_WEATHER_DATA
Limit 10;
```

## Tips & Tricks

### Add metadata column on the copy command
Can be used to add insertion time, or source system when looping over many sources to create a unified table. Or to extract part of the Json data to a seperate column on the copy.
```sql
copy into ODS.events_par_stage
from (
	  select $1,current_timestamp(),parse_json($1):EventStartTime::bigint
  from @SNOWSTAGE/events_par)
file_format = 'FILE_FORMAT';
```
