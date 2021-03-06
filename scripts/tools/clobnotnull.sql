CREATE OR REPLACE FUNCTION "SYS"."CLOBNOTNULL" (
  input clob)
  return clob
parallel_enable
aggregate
using TClobNotNull;
/
CREATE OR REPLACE PUBLIC SYNONYM "CLOBNOTNULL" FOR "SYS"."CLOBNOTNULL"
/
GRANT EXECUTE ON "SYS"."CLOBNOTNULL" TO "PUBLIC"
/
