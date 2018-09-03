#!/bin/bash
#
#
# Register database schema password in Team Password Manager - https://pwman.lstools.int.clarivate.com/
#
# Parameters:
###   -u|--username        - Username to connect to Password Manager
###   -p|--password        - Password to connect to Password Manager
#   -r|--project        - Password Manager's project name, default is Cortellis
#   -s|--schema         - Schema name to register
#   -p|--password	- Schema password to register
#   -g|--db_group	- DB Group (STAGING, CORTELLIS, etc.)
#   -e|--env        	- Environment name (DEV, QA, PROD, etc.)
#   -c|--dc             - Data Centre name (EDC, EAGAN, DTC)
#   -d|--db             - Full database name (<db_group>-<env>-<dc>, e.g. staging-dev-dtc)

if [ $# -lt 3 ] ; then
  echo "Usage: $0 \\
   -s|--schema <schema name> \\
   -p|--password <schema password> \\
   -g|--db_group       - DB Group (STAGING, CORTELLIS, etc.) \\
   -e|--env            - Environment name (DEV, QA, PROD, etc.) \\
   -c|--dc             - Data Centre name (EDC, EAGAN, DTC) \\
   -d|--db             - Full database name (<db_group>-<env>-<dc>, e.g. staging-dev-dtc) \\
   [-r/--project <project name, default is Cortellis>]"
  exit 1
fi

ARGS=`getopt -o s:p:g:e:c:d:r -l schema:,password:,db_group:,env:,dc:,db:,project -- "$@"`
if [ $? -ne 0 ]; then
  exit $?
fi
eval set -- "$ARGS"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -r|--project)
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
        -g|--db_group)
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
        *) echo "Unsupported parameter" ; exit 1 ;;
    esac
done

PROJECT=${PROJECT:-'cortellis'}

# Make it smart
case "$PROJECT" in
  'cortellis') PROJECT_ID=5 ;;
  'linguamatics') PROJECT_ID=21 ;;
  'editorial'|'editorial (former jpharm)') PROJECT_ID=8 ;;
  'genego') PROJECT_ID=1 ;;
  'prous cms'|'prous') PROJECT_ID=11 ;;
  'cii'|'cef') PROJECT_ID=14 ;;
  'clinical genomics'|'cg'|'clinical-genomics') PROJECT_ID=6 ;;
  'systems biology'|'systems-biology'|'sb') PROJECT_ID=3 ;;
  'general') PROJECT_ID=2 ;;
  'infrastructure') PROJECT_ID=13 ;;
  *) PROJECT_ID=2 ;; # General
esac

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

if [ -f "$HOME/.pwdman.credentials" ]; then
  curl -u `cat $HOME/.pwdman.credentials` -H 'Content-Type: application/json; charset=utf-8' -i https://pwman.lstools.int.clarivate.com/index.php/api/v3/my_passwords/search/.json
else
  echo "File with PwdMan credentials \"$HOME/.pwdman.credentials\" is not found"
  exit 1
fi


