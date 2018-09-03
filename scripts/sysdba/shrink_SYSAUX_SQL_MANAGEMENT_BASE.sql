set serveroutput on size 1000000 echo on

alter table "SYS"."SQL$" enable row movement;
alter table "SYS"."SQL$TEXT" enable row movement;
alter table "SYS"."SQLOBJ$AUXDATA" enable row movement;

alter table "SYS"."SQL$" shrink space cascade;
alter table "SYS"."SQL$TEXT" shrink space cascade;
alter table "SYS"."SQLOBJ$AUXDATA" shrink space cascade;

alter table "SYS"."SQL$" disable row movement;
alter table "SYS"."SQL$TEXT" disable row movement;
alter table "SYS"."SQLOBJ$AUXDATA" disable row movement;

alter table "SYS"."SQLOBJ$" shrink space cascade;
alter table "SYS"."SQLOBJ$DATA" shrink space cascade;

alter table "SYS"."SQL$" modify lob ("SPARE2") (shrink space cascade);
alter table "SYS"."SQL$TEXT" modify lob ("SPARE2") (shrink space cascade);
alter table "SYS"."SQL$TEXT" modify lob ("SQL_TEXT") (shrink space cascade);
alter table "SYS"."SQLOBJ$" modify lob ("SPARE2") (shrink space cascade);
alter table "SYS"."SQLOBJ$DATA" modify lob ("COMP_DATA") (shrink space cascade);
alter table "SYS"."SQLOBJ$DATA" modify lob ("SPARE2") (shrink space cascade);
alter table "SYS"."SQLOBJ$AUXDATA" modify lob ("SPARE2") (shrink space cascade);

