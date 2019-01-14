# Naming Conventions
Before you start with the development it is important to set some **naming convensions**.


###Databases & Schemas
Create a database for each layer:

**ODS** - <Customer\Project>_ODS - Will have 2 schemas: 
* ODS_Full - Data in json (source) structure
* ODS - Structured data, Extracted from the ODS_Full 

**DWH** - <Customer\Project>_DWH - Will have 2 schemas:
* STG - Staging Data
* DWH - Data warehouse objects

 
###Table Names

**ODS_FULL:** ODS_FULL_{Source_System}_{Table_Name} → e.g: ODS_FULL_WEB_EVENTS

**ODS:** ODS_{Source_System}_{Table_Name} → e.g: ODS_CRM_CUSTOMERS

**STG:** STG_DIM\FACT_{table_name} → e.g: STG_DIM_CUSTOMERS

**DWH:** DWH__DIM\FACT_{table_name} → e.g: DWH_DIM_CUSTOMERS

_Other_

{table_name}_Population, _Hist, _GK...

###ETL Processes
**ODS:** ODS_{Source_Type}_{Table_Name} → e.g: ods_mysql_player_brand

**DWH:** DWH_{Target_Table_Name}_{Comment**} → e.g: dwh_dim_brand \ dwh_fact_brands

** If needed, like performance

###ETL Wrappers (Groups):
**ODS:** ODS_{Source_Type} → e.g: ODS_MYSQL_PLAYER / MYSQL_GAME / GSHEET

**DWH:** DWH_{Business Model**}→ e.g: DWH_Sales



