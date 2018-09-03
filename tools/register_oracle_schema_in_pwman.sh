#!/bin/bash
#
# Register database schema password in Team Password Manager - https://pwman.lstools.int.clarivate.com/
#
USAGE="Usage: $0 \n\
   -s|--schema <schema name> \n\
   -p|--password <schema password> \n\
   -g|--db-group       - DB Group (STAGING, CORTELLIS, etc.) \n\
   -e|--env            - Environment name (DEV, QA, PROD, etc.) \n\
   -c|--dc             - Data Centre name (EDC, EAGAN, DTC) \n\
   -d|--db             - Full database name (<db_group>-<env>-<dc>, e.g. staging-dev-dtc) \n\
   [--project <project name, default is \"Cortellis\">]"

if [[ $# -eq 0 ]]; then
  echo -e $USAGE
  exit 99
fi

ARGS=`getopt -o s:p:g:e:c:d: -l schema:,password:,db-group:,env:,dc:,db:,project: -- "$@"`
if [ $? -ne 0 ]; then
  exit $?
fi
eval set -- "$ARGS"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        --project)
            case "$2" in
                "") shift 2 ;;
                *) PROJECT=`echo "$2" | tr '[:upper:]' '[:lower:]'` ; shift 2 ;;
            esac ;;
        -s|--schema)
            case "$2" in
                "") shift 2 ;;
                *) SCHEMA=`echo "$2" | tr '[:upper:]' '[:lower:]'` ; shift 2 ;;
            esac ;;
        -p|--password)
            case "$2" in
                "") shift 2 ;;
                *) PASSWORD="$2"; shift 2 ;;
            esac ;;
        -g|--db-group)
            case "$2" in
                "") shift 2 ;;
                *) DB_GROUP=`echo "$2" | tr '[:upper:]' '[:lower:]'` ; shift 2 ;;
            esac ;;
        -e|--env)
            case "$2" in
                "") shift 2 ;;
                *) ENV=`echo "$2" | tr '[:upper:]' '[:lower:]'` ; shift 2 ;;
            esac ;;
        -c|--dc)
            case "$2" in
                "") shift 2 ;;
                *) DC=`echo "$2" | tr '[:upper:]' '[:lower:]'` ; shift 2 ;;
            esac ;;
        -d|--db)
            case "$2" in
                "") shift 2 ;;
                *) DB=`echo "$2" | tr '[:upper:]' '[:lower:]'` ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) echo "Unsupported parameter - \"$1\""; echo $USAGE; exit 1 ;;
    esac
done

if [ -n "$DB" ]; then
  DB_GROUP=`echo "$DB" | cut -d '-' -f 1`
  ENV=`echo "$DB" | cut -d '-' -f 2`
  DC=`echo "$DB" | cut -d '-' -f 3`
else
  if [ -z "$DB_GROUP" ]; then
    echo '--db_group must be specified'
    exit 1
  elif [ -z "$ENV" ]; then
    echo '--env must be specified'
    exit 1
  elif [ -z "$DC" ]; then
    echo '--dc must be specified'
    exit 1
  else
    DB="$DB_GROUP-$ENV-$DC"
  fi
fi

TAGS="database,schema,lion,$ENV,$DC"
if [ "$ENV" != 'prod' ]; then
  TAGS="$TAGS,non-prod"
fi
if [ "$DB_GROUP" == 'cortellis' ]; then
  TAGS="$TAGS,cfdb"
else
  TAGS="$TAGS,$DB_GROUP"
fi

_db_connection=$(tnsping $DB 2>/dev/null | grep -E '\(DESCRIPTION.*' | sed -r 's/^Attempting to contact //')
echo $_db_connection
if [[ -n $_db_connection ]]; then
  echo $_db_connection | awk '/\(DESCRIPTION/ {
gsub("[()=]"," ")
$0=toupper($0)
for (i=1;i<=NF;i++)
   if ($i=="HOST")
       {print $(i+1)
        exit}
}' | read _db_host
  echo $_db_connection | awk '/\(DESCRIPTION/ {
gsub("[()=]"," ")
$0=toupper($0)
for (i=1;i<=NF;i++)
   if ($i=="PORT")
       {print $(i+1)
        exit}
}' | read _db_port
  echo $_db_connection | awk '/\(DESCRIPTION/ {
gsub("[()=]"," ")
$0=toupper($0)
for (i=1;i<=NF;i++)
   if ($i=="SERVICE_NAME")
       {print $(i+1)
        exit}
}' | read _db_service_name
fi
echo register_password_in_pwman.sh --name "${SCHEMA}@${DB}" --password "$PASSWORD" --project "$PROJECT" --tags "$TAGS" --username $SCHEMA --access-url "jdbc:oracle:thin:@${_db_host}:${_db_port}\/${_db_service_name}"
register_password_in_pwman.sh --name "${SCHEMA}@${DB}" --password "$PASSWORD" --project "$PROJECT" --tags "$TAGS" --username $SCHEMA --access-url "jdbc:oracle:thin:@${_db_host}:${_db_port}\/${_db_service_name}"
