import snowflake.connector
import config
import json
import pandas as pd
from datetime import datetime

from jinja2 import Template

sf_conn = {'account': config.ACCOUNT,
               'user': config.USER,
               'password': config.PASS,
               'application': config.APPLICATION,
               'role': config.ROLE,
               'warehouse': config.WAREHOUSE,
               'database': config.DATABASE,
               'schema': config.SCHEMA,
               'session_parameters': {'QUERY_TAG': json.dumps({'job_name': 'Job A'})}
               }

def run_sql(sql_templae, params, stop_on_error= False):
    try:
        started = datetime.now()
        res_obj = {"started": datetime.now()}

        with snowflake.connector.Connect(autocommit=True, **sf_conn) as db_:
            cur = db_.cursor()
            parsed_sql = Template(sql_templae).render(**params)
            sqlCommands = parsed_sql.split(';')

            # Execute every command from the input file
            for sql_command in sqlCommands:
                try:
                    if (len(sql_command) > 4):
                        print('')
                        print('Executing SQL:', '\t', ' Started:', datetime.now().strftime('%H:%M:%S'))
                        print(sql_command.replace('\n', ' '))

                        try:
                            cur.execute(sql_command)
                            results = cur.fetchall()

                            df = pd.DataFrame(results, columns=[x[0] for x in cur.description])
                        except Exception as e:
                            df = pd.DataFrame([str(e)], columns=['ERROR'])
                            if(stop_on_error):
                                raise

                        print('Result:', '\t', ' Duration:', (datetime.now() - started).total_seconds(),
                              ' Second(s)')
                        print(df.to_string())

                except Exception as e:
                    print('Result:', '\t', ' Duration:', (datetime.now() - started).total_seconds(), ' Second(s)')
                    df = pd.DataFrame([str(e)], columns=['ERROR'])
                    print(df.to_string())

                    if (stop_on_error):
                        raise

            res_obj.update({"duration": (datetime.now() - started).total_seconds()})


    except Exception as e:
        print('Failed to connect to Snowflake')
        print(str(e))
        if (stop_on_error):
            raise

if __name__ == '__main__':
    sql_templae="""
                USE ROLE {{role}};
                SHOW DATABASES;
                Select '{{param2}}' AS Column_Name from {{table_name}};
                Select 'Fail on purpose' Fail_on_purpose From None_Existing_Table;
                """

    params = {"role":"SYSADMIN",
              "param2":"Some Param",
              "table_name":"Dual"}

    run_sql(sql_templae = sql_templae, params=params, stop_on_error = False)
