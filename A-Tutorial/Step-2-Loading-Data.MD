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
create or replace TABLE ODS.ODS_EVENTS (
	O_ORDERKEY NUMBER(38,0),
	O_CUSTKEY NUMBER(38,0) ,
	O_ORDERSTATUS VARCHAR(1),
	O_TOTALPRICE NUMBER(12,2),
	O_ORDERDATE DATE  NULL,
	O_ORDERPRIORITY VARCHAR(15),
	O_CLERK VARCHAR(15),
	O_SHIPPRIORITY NUMBER(38,0),
	O_COMMENT VARCHAR(79) )
COMMENT='Created for Zero to Snowflake'
;
```

## Copy Data from S3 using STAGE
To avoid sharing and using the access and secret key on each query, it is recommended to create a STAGE once, and then execute the copy commands from that STAGE


###Create STAGE (for CSV format)
#### Create command
```sql
create or replace STAGE SNOWSTAGE_CSV
    url='s3://<bucket>/sample_data'
    credentials = (AWS_KEY_ID='...' 
                   AWS_SECRET_KEY='...' )
    FILE_FORMAT = (type=CSV);
```

#### Explore files 
```sql
Select $1, $2, $3, $4
from @SNOWSTAGE_CSV/orders_csv
limit 10;
```

#### Load data
*Create warehouse using the UI
```sql
copy into ODS.ODS_EVENTS
from @SNOWSTAGE_CSV/orders_csv
ON_ERROR=CONTINUE;
```
#### Load data advanced example
*Custom column, calculated fields, default values...
```sql
copy into ODS.ODS_EVENTS (O_ORDERKEY, O_CUSTKEY, O_ORDERSTATUS, O_TOTALPRICE,O_ORDERDATE )
from (Select $1, $2, $3, $4, current_timestamp()
from @SNOWSTAGE_CSV/orders_csv
     limit 10)
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
###Create Stage (For PARQUET)
#### Create command
```sql
create or replace STAGE SNOWSTAGE
    url='s3://<bucket>/sample_data'
    credentials = (AWS_KEY_ID='...' 
                   AWS_SECRET_KEY='...' )
    FILE_FORMAT = (type=PARQUET);
```
#### Explore files 
```sql
select $1
from @SNOWSTAGE/weather_parquet
limit 10;
```
#### Customize structure 
```sql
select parse_json($1:_COL_0),current_timestamp(),parse_json($1:_COL_0):time::datetime
from @SNOWSTAGE/weather_parquet
limit 10;
```


#### Create a target table 
```sql
Use database Snowdemo;
create or replace TABLE ODS.ODS_WEATHER_PAR (json_data variant, inserted timestamp_ltz, created datetime)
COMMENT='Create for Zero to Snowflake - with parquet'
;
Show tables;
```

###Load From Stage
```sql
copy into ODS.ODS_WEATHER_PAR
from (
    select parse_json($1:_COL_0),current_timestamp(),parse_json($1:_COL_0):time::datetime
    from @SNOWSTAGE/weather_parquet
)
file_format = (type=PARQUET);
```
* L WH, 5m13s


### Quering Semi-Structure data
Use <column-name>:<attribute> to query the data
	
```sql
select  //JSON_DATA:city,
        JSON_DATA:city:id id,
        JSON_DATA:city:name::string name,
        JSON_DATA:city:coord:lat latitude,
        JSON_DATA:city:coord:lon longitude,
        JSON_DATA:city:country::string country
From ODS.ODS_WEATHER_PAR
```

## External Tables
The last part for the perfect data lake implementation

### Create
```sql
create or replace external table ODS.EXT_WEATHER_PAR(
  METADATA string as metadata$filename,
//  DATE_ID date as to_date(substr(metadata$filename, 12, 10), 'YYYY/MM/DD'),
  JSON_DATA variant as (parse_json(value:_COL_0)),
  CREATED timestamp_ltz as (current_timestamp())
)
//partition by (DATE_ID)
  location=@SNOWSTAGE/weather_parquet
  file_format = (type=PARQUET);
```

### Refresh
```sql
alter external table ODS.EXT_WEATHER_PAR refresh;
```

### Query
```sql
Select *
From ODS.EXT_WEATHER_PAR
limit 10;
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

### Read query history
Usefull for monitoring data loading and alerts
```sql
Select *
From (Select * FROM table(result_scan(last_query_id())) )
Where "errors_seen">0;
```

### The Snowflake Database

```sql
Select *
From "SNOWFLAKE"."ACCOUNT_USAGE"."QUERY_HISTORY"
Limit 10;
```

```sql
Select *
From "SNOWFLAKE"."ACCOUNT_USAGE"."WAREHOUSE_METERING_HISTORY"
Limit 10;
```



