--
-- table grep function
--
-- Copyright(c) 2013 Uptime Technologies, LLC.
--
CREATE OR REPLACE FUNCTION grep(searchkey TEXT, relname NAME)
  RETURNS SETOF text
AS $$
DECLARE
  _searchkey ALIAS FOR $1;
  _relname ALIAS FOR $2;
  _query TEXT;
  _attlist TEXT;
  _rec RECORD;
BEGIN
  _attlist = '';
  FOR _rec IN SELECT attname::text
                FROM pg_attribute a, pg_class c
               WHERE c.relname = _relname
                 AND c.relkind IN ( 'r', 'v' )
                 AND c.oid = a.attrelid LOOP
    IF _attlist = '' THEN
      _attlist = 'coalesce("' || _rec.attname || '"::text,'''')';
    ELSE
      _attlist = _attlist || ' || ' || ''',''' || ' || coalesce("' || _rec.attname || '"::text,'''')';
    END IF;
  END LOOP;

  _query = 'SELECT ' || _attlist || ' AS line FROM "' || _relname || '" WHERE ' || _attlist || ' LIKE ''%%' || _searchkey || '%%''';

--   RAISE NOTICE '%', _query;

  FOR _rec IN EXECUTE _query LOOP
    RETURN NEXT _rec.line;
  END LOOP;
END
$$ LANGUAGE 'plpgsql';
