/*SETUP SCRIPT EXAMPLE*/
/*
This script contains both commands for a setup process (creates Warehouses, Databases
etc.)
and commands for securiaty object (Users, Roles).
It should be edited before run, with the Account's specific information, i.e. the names of the
objects, the size of the Warehouse etc.
*/
Use role ACCOUNTADMIN;

/*CREATE WHAREHOUSES
A Warehouse is the compute unit which executes the queries and operations (like COPY and UNLOAD).
Each Warehouse is set to a specific size, which determines both the 'power' of the Warehouse and its cost per hour.
*/
CREATE OR REPLACE WAREHOUSE SOME_WAREHOUSE
WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 60 AUTO_RESUME = TRUE;

/* CREATE USERS
Each person should have its own User.
When creating a User we specify the following parameters, while only the NAME is required.
for more information - https://docs.snowflake.com/en/sql-reference/sql/create-user.html
*/
Use role SECURITYADMIN;
CREATE USER IF NOT EXISTS "<NAME>" LOGIN_NAME = '<user_name>'
DISPLAY_NAME = 'FirstName LastName' EMAIL = 'address@domain.com'
PASSWORD = 'initial_password_to_be_changed_later' MUST_CHANGE_PASSWORD =
TRUE
DEFAULT_WAREHOUSE = 'SOME_WAREHOUSE' DEFAULT_ROLE = "SOME_ROLE";

/* CREATE ROLES
The Role object will have privileges on the securable objects of the account.
The built-in Roles are ACCOUNTADMIN, SECURITYADMIN and SYSADMIN
*/
CREATE ROLE IF NOT EXISTS "SOME_ROLE";

/* GRANT ROLES
Users will be granted the privileges by having access to a Role
*/
GRANT ROLE "SOME_ROLE" TO USER "<NAME>";
/*
In case we want specific Users to use the built-in Roles
The ACCOUNTADMIN Role already inherits the other two Roles
*/
GRANT ROLE ACCOUNTADMIN TO USER "<NAME>";
// GRANT ROLE SECURITYADMIN TO USER "<NAME>"
// GRANT ROLE SYSADMIN TO USER "<NAME>";

/* FOR ROLES HIERARCHY
All custom (user-created) Roles shoule be granted to the SYSADMIN built-in Role
*/
GRANT ROLE "SOME_ROLE" TO ROLE sysadmin;

/* CREATE DATABASES AND SCHEMAS
This objects can be create by the SYSADMIN Role or by a custom Role.
The one used is the owner of the object.
*/
Use role SYSADMIN; /* Can also be 'Use role SOME_ROLE'; */
create or replace database "DB_NAME";
create schema "SCHEMA_NAME";

/* PERMISSIONS TO DATABASE AND SCHEMAS
Granting privileges on an object like Table, should be in addition to granting USAGE privilege to
its container object, i.e. Schema and Database.
Important - Privileges shoule be granted to Roles only, not to Users.
For more information about priviliages -
https://docs.snowf
