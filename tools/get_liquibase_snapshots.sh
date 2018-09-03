#!/bin/bash
DB=${1:-'db_connection'}
SCHEMA=$2

. ~/oracle-dba/tools/dba_functions

JDBC_CONN=`convert_tns_to_jdbc $DB`

. ~/.dba_passwords

liquibase --classpath=$ORACLE_HOME/jdbc/lib/ojdbc6.jar --driver=oracle.jdbc.OracleDriver \
  --url $JDBC_CONN --username=$ADMIN_USER --password=$ADMIN_PWD \
  snapshot \
  --defaultSchemaName=${SCHEMA} --outputDefaultSchema=true --outputFile=${SCHEMA}_${DB}.snapshot \
  --logLevel=DEBUG --logFile=${SCHEMA}_${DB}.log
