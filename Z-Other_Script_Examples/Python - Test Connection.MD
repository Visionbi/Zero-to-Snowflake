
### Load data from Elasticsearch
Sample code


```python

import snowflake.connector

# Connecting to Snowflake using the default authenticator
cnx = snowflake.connector.connect(
    account='...',
    user='...',
    password='...',
    database='SNOWDEMO',
    warehouse='DEMO_WH'
)
sql = "use database SNOWDEMO;"
cnx.cursor().execute(sql)
print("Connected to Database SNOWDEMO...")

sql = "Select 'Success'"
cur_res = cnx.cursor().execute(sql)
for r in cur_res:
    print("ODS.INC_{dt} - {r} Row(s) Inserted ".format(r=r[0],dt=_doc_type))
