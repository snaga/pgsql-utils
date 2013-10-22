--
-- table grep function
--
-- Copyright(c) 2013 Uptime Technologies, LLC.
--
CREATE OR REPLACE FUNCTION grep(searchkey TEXT, relname NAME)
RETURNS table("relation" TEXT, "match" TEXT)
LANGUAGE 'plpgsql'
AS $$
DECLARE
  _query TEXT;
BEGIN
    WITH t AS (
        SELECT
            quote_ident(table_schema) AS "schema",
            quote_ident(table_name) AS "table",
            quote_ident(table_schema) || '.' || quote_ident(table_name) AS "full_name"
        FROM
            information_schema.tables
        WHERE
            table_name ~ relname AND 
            table_schema NOT IN ('pg_catalog','information_schema')

    )
    SELECT INTO _query string_agg(
        '    SELECT ' || quote_literal(full_name) || ', (' || "table" || ')::text' ||
           ' FROM ' || "full_name" ||
           ' WHERE (' || "table" || ')::text ~ ' || quote_literal(searchkey),
        E'\nUNION ALL\n'
    )
    FROM t;

    RAISE NOTICE E'Query is\n%', _query;

    RETURN QUERY EXECUTE _query;
END;
$$;
