# Access Control
The following is a basic intro for the Access Control model in Snowflake. For more details, visit [Security Access Control Overview](https://docs.snowflake.com/en/user-guide/security-access-control-overview.html) 


###General Concept
 
* **Discretionary Access Control (DAC)**: Each object has an owner, who can in turn grant access to that object.

* **Role-based Access Control (RBAC)**: Access privileges are assigned to roles, which are in turn assigned to users.

 ![alt text](https://docs.snowflake.com/en/_images/access-control-relationships.png "Access Control Relationships")

####Roles Hierarchy
 ![alt text](https://docs.snowflake.com/en/_images/system-role-hierarchy.png "System Role Hierarchy")
There are 4 built-in Roles:

**ACCOUNTADMIN** - A role that encapsulates the SYSADMIN and SECURITYADMIN system-defined roles. It is the
top-level role in the system and should be granted only to a limited/controlled number of users in
your account.

**SECURITYADMIN** - A role that can create, monitor, and manage users and roles. More specifically, this role is used
to:
* Create users and roles in your account (and grant those privileges to other roles).
* Modify and monitor any user, role, or session.
* Modify any grant, including revoking it.

**SYSADMIN** - A Role that has privileges to create warehouses and databases (and other objects) in an
account.
If, as recommended , you create a role hierarchy that ultimately assigns all custom roles to the
SYSADMIN role, this role also has the ability to grant privileges on warehouses, databases, and
other objects to other roles.

**PUBLIC** - Pseudo-role that is automatically granted to every user and every role in your account. The
PUBLIC role can own securable objects, just like any other role; however, the objects owned by
the role are, by definition, available to every other user and role in your account.
This role is typically used in cases where explicit access control is not needed and all users are
viewed as equal with regard to their access rights.


###Privileges
Privileges are granted to roles, and roles are granted to users, to specify the operations that the users can perform on objects in the system.
Each securable object has different privileges that can be granted on. For example, Table object has SELECT, DELETE, INSERT etc privileges, while Warehouse object has USAGE, MODIFY, OPERATE etc privileges.
 
To learn more about [Access Control Privileges](https://docs.snowflake.com/en/user-guide/security-access-control-privileges.html)

###Access Control Considerations
These are recommended, when implementing a security model:
  
* **ACCOUNTADMIN** should be granted to a minimum set of users (at least 2), that will use
multi-factor authentication ( MFA ) .
* Associate a real person’s email address to the ACCOUNTADMIN role.
* **Avoid** using the ACCOUNTADMIN role to create objects! - It helps if you will not specify the
ACCOUNTADMIN as the default role for a User.
* Avoid using the ACCOUNTADMIN role for **automated scripts** , mostly SYSADMIN is
enough. Except for roles/users manipulation, which requires SECURITYADMIN.
* A **USAGE** privilege is required on a container object (e.g. database, schema), in addition
to the privilege (e.g. select) on the actual low-level object (e.g. table).
* All custom roles should be **granted to SYSADMIN** . Otherwise, the ACCOUNTADMIN
will not have access to this custom role’s objects.
* For further security, make the schema **“managed”**. This means only the Schema owners
will be able to grant privileges in schema’s object. This instead of the objects’ owners
themselves. Use WITH MANAGED ACCESS when creating the schema or ENABLE |
DISABLE MANAGED ACCESS when altering the schema.
* Use **FUTURE GRANTS** - for new objects only, not existing. e.g. 
```sql
grant select on future tables in schema DB_NAME.SCHEMA_NAME to role SOME_ROLE;
```
 
* Combine roles for **business** units with roles for **databases** object access, to achieve
maximum agility, in a hierarchical structure. As shown in the following image
![alt text](https://docs.snowflake.com/en/_images/role-hierarchy-practical.png "Role Hierarchy Practical")
For more information, visit [Access Control Considerations](https://docs.snowflake.com/en/user-guide/security-access-control-considerations.html)


