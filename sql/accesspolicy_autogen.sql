--
-- permission_autogen.sql
--
-- Copyright(c) 2013 Uptime Technologies, LLC.
--
SELECT 'REVOKE ALL ON DATABASE ' || current_database() || ' FROM ' || current_user || ';'
UNION ALL
SELECT 'REVOKE ALL ON ' || schemaname || '.' || relname || ' FROM ' || user || ';'
  FROM pg_stat_user_tables
UNION ALL
SELECT CASE WHEN regexp_replace(priv, ',$', '') = '' THEN
         'REVOKE ALL ON ' || rel || ' FROM ' || user || ';'
       ELSE
         'GRANT ' || regexp_replace(priv, ',$', '') || ' ON ' || rel || ' TO ' || user || ';'
       END
  FROM ( SELECT CASE WHEN coalesce(seq_tup_read,0)+coalesce(idx_tup_fetch,0) > 0 THEN 'SELECT,'
                     ELSE ''
                END ||
                CASE WHEN coalesce(n_tup_ins,0) > 0 THEN 'INSERT,'
                     ELSE ''
                END ||
                CASE WHEN coalesce(n_tup_upd,0)+coalesce(n_tup_hot_upd,0) > 0 THEN 'UPDATE,'
                     ELSE ''
                END ||
                CASE WHEN coalesce(n_tup_del,0) > 0 THEN 'DELETE'
                     ELSE ''
                END AS "priv",
                schemaname || '.' || relname AS "rel",
                current_user AS "user"
           FROM pg_stat_user_tables ) AS t;
