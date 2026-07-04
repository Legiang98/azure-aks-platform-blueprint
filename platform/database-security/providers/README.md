# Database Security Providers

This folder contains Pulumi dynamic providers for database security baselines.

Supported providers:

- `azure-sql-database.ts`
- `postgresql-database.ts`

These providers manage users, roles, grants, and connection string helpers. They do not manage application schema objects such as tables, columns, indexes, views, stored procedures, or seed data.
