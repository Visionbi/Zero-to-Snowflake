
### Sample Python
Execute SQL


```python

#pip install snowflake-connector-python
import snowflake.connector


# Setting your account information
ACCOUNT = '<account>.eu-central-1' #Change region if needed
USER = '...'
PASSWORD = '...'
DATABASE = '...'
WAREHOUSE = '...'
ROLE = '...'

# Connecting to Snowflake using the default authenticator
cnx = snowflake.connector.connect(
    user=USER,
    password=PASSWORD,
    account=ACCOUNT,
    database=DATABASE,
    warehouse=WAREHOUSE,
    role=ROLE
)



def snow_sql_command():
    sql = "Create or Replace table public.sample_table(User_id number, User_Name String, Created_Date datetime)"
    sql_res = cnx.cursor().execute(sql)
    return sql_res.rowcount

def snow_insert():
    vals = []
    user_id = 1
    user_name = 'Sample User'

    row_str = "('" + str(user_id) + "','" + str(user_name) + "')"
    vals.append(row_str)
    values = ','.join(vals)

    insert_sql = "INSERT INTO  public.sample_table" \
                 "(User_id , User_Name) " \
                 " VALUES {v}".format(v=values.replace("'None'", "Null"))
    sql_res = cnx.cursor().execute(insert_sql)
    return sql_res.rowcount

def snow_select_command():
    rows=[]
    sql = """Select User_id, Count(*) cnt
    From public.sample_table
    Group by 1
    Order by 2 Desc
    """
    sql_res = cnx.cursor().execute(sql)
    for row in sql_res:
        rows.append(row)
    return rows


if __name__ == "__main__":
    print (snow_sql_command())
    print (snow_insert())
    print (snow_select_command())
```