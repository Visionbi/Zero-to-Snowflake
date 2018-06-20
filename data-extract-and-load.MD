
## Create & Resizing Warehouses

```sql
CREATE or REPLACE WAREHOUSE DEMO_WH
WITH WAREHOUSE_SIZE = 'MEDIUM'
     WAREHOUSE_TYPE = 'STANDARD'
     AUTO_SUSPEND = 300
     AUTO_RESUME = TRUE;
```

```sql
USE WAREHOUSE DEMO_WH;
show warehouses;
Use database snowdemo;
```
```sql
create or replace TABLE ODS.ODS_WEB_EVENTS_OBJ
(json_data variant)
COMMENT='Thanks you to Cignal.io'
;
```
```sql
copy into ODS.ODS_WEB_EVENTS_OBJ
from s3://path/to/folder/
credentials = (AWS_KEY_ID='...' 
               AWS_SECRET_KEY='...')
FILE_FORMAT = (type=JSON)
ON_ERROR=CONTINUE;
```
### Resize WH and Run Again

```sql
copy into ODS.ODS_WEB_EVENTS_OBJ
from s3://path/to/folder/
credentials = (AWS_KEY_ID='...' 
               AWS_SECRET_KEY='...')
FILE_FORMAT = (type=JSON)
ON_ERROR=CONTINUE;
```

```sql
// *********************
// ** Extract & Merge **
// *********************

//Count
use schema ODS;
show tables;

select  Count(*)
From ODS.ODS_WEB_EVENTS_OBJ;

//Json Data
select  *
From ODS.ODS_WEB_EVENTS_OBJ
Limit 10;

//Query Json Data
select  JSON_DATA:id::string as id,
        JSON_DATA:ext.timestamp::double as event_time,
        JSON_DATA:ext.timestamp::timestamp as event_time_dt,
        JSON_DATA:seatbid[0].seat::string as seat,
        JSON_DATA:seatbid[0].bid[0].impid::string as imp_id,
        JSON_DATA:seatbid[0].bid[0].id::string as bid_id,
        JSON_DATA:seatbid[0].bid[0].price/uniform(1, 10, random()) as bid_price
From ODS.ODS_WEB_EVENTS_OBJ
//Where JSON_DATA:ext.timestamp::double>=1529280502076
Limit 100;

//Convert Data Types
select  JSON_DATA:ext.timestamp,
JSON_DATA:seatbid[0].seat::string,
JSON_DATA:seatbid[0].seat,
(JSON_DATA:ext.timestamp/1000)::int::timestamp,
TRY_TO_TIMESTAMP((JSON_DATA:ext.timestamp/1000)::int::string)
From ODS.ODS_WEB_EVENTS_OBJ
Where JSON_DATA:ext.timestamp::double > 1529357543948
Limit 10;


select  Count(*)
From ODS.ODS_WEB_EVENTS_OBJ
Where JSON_DATA:ext.timestamp::double<=1529280502076;
      
//Extract Json Data
create or replace view ODS.ODS_WEB_EVENTS_INC_V as
Select *
From (
      select  row_number() over(partition by JSON_DATA:seatbid[0].bid[0].id::string order by JSON_DATA:ext.timestamp desc) rnk,
              JSON_DATA:id::string as id,
              JSON_DATA:ext.timestamp::double as event_time,
              JSON_DATA:ext.timestamp::timestamp as event_time_dt,
              JSON_DATA:seatbid[0].seat::string as seat,
              JSON_DATA:seatbid[0].bid[0].impid::string as imp_id,
              JSON_DATA:seatbid[0].bid[0].id::string as bid_id,
              JSON_DATA:seatbid[0].bid[0].price/uniform(1, 10, random()) as bid_price
      From ODS.ODS_WEB_EVENTS_OBJ
  ) a
Where rnk = 1 
;

select bid_id, count(*)
From ODS.ODS_WEB_EVENTS_INC_V
Group by 1 
Having count(*)>1
order by 2 desc;

Select *
From ODS.ODS_WEB_EVENTS_INC_V
Where  event_time  > 1529357543948;

create or replace table ODS.ODS_WEB_EVENTS as
select  row_number() over(partition by JSON_DATA:seatbid[0].bid[0].id::string order by JSON_DATA:ext.timestamp desc) rnk,
        JSON_DATA:id::string as id,
        JSON_DATA:ext.timestamp::double as event_time,
        JSON_DATA:ext.timestamp::timestamp as event_time_dt,
        JSON_DATA:seatbid[0].seat::string as seat,
        JSON_DATA:seatbid[0].bid[0].impid::string as imp_id,
        JSON_DATA:seatbid[0].bid[0].id::string as bid_id,
        JSON_DATA:seatbid[0].bid[0].price/uniform(1, 10, random()) as bid_price
From ODS.ODS_WEB_EVENTS_OBJ
Limit 1;

MERGE INTO ODS.ODS_WEB_EVENTS as target 
  using (Select * 
         From ODS.ODS_WEB_EVENTS_INC_V 
//         Where  event_time  > 1529357543948
        ) as source_t
  ON  target.bid_id=source_t.bid_id
  when matched then update set
      seat=source_t.seat,
      bid_price=source_t.bid_price

when not matched then insert (bid_id,rnk,id,event_time,event_time_dt,seat,imp_id,bid_price) 
              values (
              source_t.bid_id,source_t.rnk,source_t.id,source_t.event_time,
              source_t.event_time_dt,source_t.seat,source_t.imp_id,source_t.bid_price
            );
                            

create or replace table ODS.ODS_WEB_EVENTS as
select  JSON_DATA:id::string as id,
        JSON_DATA:ext.timestamp as event_time,
        JSON_DATA:seatbid[0].seat::string as seat,
        JSON_DATA:seatbid[0].bid[0].id::string as bid_id,
        JSON_DATA:seatbid[0].bid[0].price/uniform(1, 10, random()) as bid_price
From ODS.ODS_WEB_EVENTS_OBJ
;


// ************************
// ** Micro Partitioning **
// ************************


Select SYSTEM$CLUSTERING_RATIO( 'ODS.ODS_WEB_EVENTS');
Select SYSTEM$CLUSTERING_INFORMATION( 'ODS.ODS_WEB_EVENTS');

select  count(*)//JSON_DATA:ext.timestamp::double,*
From ODS.ODS_WEB_EVENTS
Where JSON_DATA:ext.timestamp::double > 1529357543948
Limit 10;

drop table ODS.ODS_WEB_EVENTS;


select  count(*)//JSON_DATA:ext.timestamp::double,*
From ODS.ODS_WEB_EVENTS;

undrop table ODS.ODS_WEB_EVENTS;

select  count(*)//JSON_DATA:ext.timestamp::double,*
From ODS.ODS_WEB_EVENTS
Where JSON_DATA:ext.timestamp::double > 1529357543948
Limit 10;
```
