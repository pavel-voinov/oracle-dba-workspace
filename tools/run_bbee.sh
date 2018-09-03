#!/bin/bash
#
# do not use it for production
#
COMPONENT=` echo $1 | tr 'A-Z' 'a-z'`
VERSION=${2:-'1.0'}
ENV=${3:-'cc-greenplum-dev'}
if [[ -z $COMPONENT ]]; then
  echo "Please specify component to deploy"
  exit 99
fi

pushd ${BBEE_HOME:-"$HOME/Bumbleebee_for_Greenplum"}

if [[ ! -d $COMPONENT ]]; then
  echo "$COMPONENT directory not found in BumbleBee home. Please, deploy component scripts first"
  retval=1
elif [[ ! -d $COMPONENT/app-conf/$ENV ]]; then
  echo "$ENV directory not found in $COMPONENT/app-conf/. Please, check if component has environment-specific configuration"
  retval=2
else
  mkdir -p logs/$COMPONENT
  python bin/do_bumblebee.py $ENV $COMPONENT $VERSION $COMPONENT/app-conf/$ENV
  retval=$?
fi

popd

exit $retval
