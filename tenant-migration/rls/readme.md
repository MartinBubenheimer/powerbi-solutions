Scripts to support anlyzing RLS configurations in a tenant to prepare for a tenant migration.

Typically, in a tenant migration, user principal names in the data need to be replaced with or extended by user principal names from the new tenant. E.g., user me@source-tenant.com becomes me@destination-tenant.com. These scripts help with identifying affected semantic models and their rules and tables that need to be modified.

Scripts with file extension .py are Python. Purpose and compatible Python versions are listed in each script.
