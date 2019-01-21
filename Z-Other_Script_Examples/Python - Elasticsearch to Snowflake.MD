
### Load data from Elasticsearch
Sample code


```python

import json
import snowflake.connector
from elasticsearch import Elasticsearch
from elasticsearch.connection import RequestsHttpConnection
import hashlib

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
es = Elasticsearch([{'host': '212...', 'port': 9200}],
                   connection_class=RequestsHttpConnection)


def load_index(_index_name, _doc_type):
    # Create (Empty) Staging Table (Increment)
    sql = "create or replace table ODS.INC_{dt}(json_data variant);".format(dt=_doc_type)
    cnx.cursor().execute(sql)
    print("Table ODS.INC_{dt} was Created...".format(dt=_doc_type))

    #Create Target Table
    sql = "create table IF NOT EXISTS ODS.ODS_{dt}(id string,row_created TIMESTAMP_LTZ, row_updated TIMESTAMP_LTZ , json_data variant);".format(dt=_doc_type)
    cnx.cursor().execute(sql)
    print("Table ODS.ODS_{dt} was Created...".format(dt=_doc_type))


    # Search Elastic
    doc = {
        'size': 50,
        'query': {
            'match_all': {}
        }
    }
    res = es.search(index=_index_name, doc_type=_doc_type , body=doc,scroll='1m')
    scroll = res['_scroll_id']

    try:
        while scroll:
            vals = []
            for hit in res["hits"]["hits"]:
                source = hit['_source']
                #Hash Data
                for att in ["hair_color","skin_color","eye_color"]:
                    if att in source.keys():
                        source.update({att:hashlib.sha256(source[att].encode()).hexdigest()})

                hit['_source'] = source
                vals.append("('" + json.dumps(hit) + "')")
                # vals.append("('" + json.dumps(hit, default=json_util.default) + "')")

            values = ','.join(vals)

            insert_sql = "INSERT INTO ODS.INC_{dt}(json_data) select parse_json(column1) from VALUES {v}"\
                            .format(dt=_doc_type ,v=values)
            cur_res = cnx.cursor().execute(insert_sql)
            for r in cur_res:
                print("ODS.INC_{dt} - {r} Row(s) Inserted ".format(r=r[0],dt=_doc_type))

            break
            #Todo: Add Pagination
            # res = es.scroll(scroll_id=scroll, scroll='1m')
            # scroll = res['_scroll_id']
    except:
        pass

    insert_sql = """
            MERGE INTO ODS.ODS_{dt} as target 
              using (Select * 
                     From ODS.INC_{dt}
                    ) as source_t
              ON  target.ID = source_t.JSON_DATA:_id::string
              when matched then update set
                  JSON_DATA=source_t.JSON_DATA:_source,
                  row_updated = current_timestamp()
              when not matched then insert (id, json_data, row_created) 
                          values (
                          source_t.JSON_DATA:_id::string, source_t.JSON_DATA:_source, current_timestamp()
                        );
    """.format(dt=_doc_type)
    cur_res = cnx.cursor().execute(insert_sql)

    for r in cur_res:
        print("ODS.ODS_{dt} - {r} Row(s) Inserted".format(r=r[0],dt=_doc_type))
        print("ODS.ODS_{dt} - {r} Row(s) Updated".format(r=r[1],dt=_doc_type))



if __name__ == "__main__":
    index = 'sw'
    doc_type='people'
    load_index(index, doc_type)



```