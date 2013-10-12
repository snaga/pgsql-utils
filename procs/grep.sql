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
  _query1 TEXT;
  _query TEXT;
  _attlist TEXT;
  _rec1 RECORD;
  _rec2 RECORD;
  _rec3 RECORD;
BEGIN
  _query1 = 'SELECT oid,relname
               FROM pg_class
              WHERE relname LIKE ''%' || _relname || '%''
                AND relkind IN ( ''r'', ''v'' )
              ORDER BY relname';

  FOR _rec1 IN EXECUTE _query1 LOOP 

--    RAISE NOTICE 'relname=%, oid=%', _rec1.relname, _rec1.oid;

    --
    -- build attribute list
    --
    _attlist = '';

    FOR _rec2 IN SELECT attname::text
                   FROM pg_attribute a
                  WHERE a.attrelid = _rec1.oid
                    AND a.attnum > 0
                  ORDER BY a.attnum LOOP

      IF _attlist = '' THEN
        _attlist = 'coalesce("' || _rec2.attname || '"::text,'''')';
      ELSE
        _attlist = _attlist || ' || ' || ''',''' || ' || coalesce("' || _rec2.attname || '"::text,'''')';
      END IF;
    END LOOP;

    _query = 'SELECT ' || _attlist || ' line FROM "' || _rec1.relname || '" WHERE ' || _attlist || ' LIKE ''%%' || _searchkey || '%%''';

--    RAISE NOTICE '%', _query;

    FOR _rec3 IN EXECUTE _query LOOP
      RETURN NEXT _rec1.relname || ',' || _rec3.line;
    END LOOP;
  END LOOP;
END
$$ LANGUAGE 'plpgsql';
