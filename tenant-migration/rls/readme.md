Scripts to support anlyzing RLS configurations in a tenant to prepare for a tenant migration.

Typically, in a tenant migration, user principal names in the data need to be replaced with or extended by user principal names from the new tenant. E.g., user me@source-tenant.com becomes me@destination-tenant.com. These scripts help with identifying affected semantic models and their rules and tables that need to be modified.

Popular modification scenarios can be solved by:

1. Adding additional rows with the user names from the new tenant.
2. Adding an addtional column with the user names from the new tenant and modifying the RLS rules (typically results in slow measure performance)
3. Adding a new security table and modifying RLS rules, e.g., if previously parts of the user principal name were extracted that are no longer available in the destination tenant to implement the RLS rules.

Scripts with file extension .py are Python. Purpose and compatible Python versions are listed in each script.
