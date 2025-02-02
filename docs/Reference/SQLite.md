# Inspecting Tables

Get a list of the tables in this database file:

```
sqlite> .tables
```

Get column information for a named table:

```
sqlite> pragma table_info(<table_name>);
```

Execute a list of commands from a file:

```
sqlite> .read file_name.sql
```
