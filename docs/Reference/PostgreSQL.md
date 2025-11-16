# PostgreSQL quick reference

```
\l                # List all databases
\c <db_name>      # Connect to a certain database
\dt               # List tables in the current database (using search_path)
\dt *.            # Same, but ignores search_path
\d+ <table_name>  # Show schema of the table with table_name.
```

Change user ("role") password:
```
ALTER USER tandoor WITH PASSWORD 'newpassword';
```

# SQL Quick Reference

Inserting data:
```
INSERT INTO <table> (<column>, ...) VALUES ('test', 1, ...);
```

Deleting data:
```
DELETE FROM <table> WHERE <condition>;
```
