#!/bin/sh -ex

#get script location
SCRIPTDIR=`dirname $0`
SCRIPTDIR=`(cd $SCRIPTDIR ; pwd)`
#get working directory
TOP=`pwd`
JOB_NAME=`echo $1`
isDelivery=`echo ${JOB_NAME} | grep delivery` || true

${TOP}/scratch/build/scripts/build.sh ${JOB_NAME}
${TOP}/scratch/build/scripts/build_runtime.sh ${JOB_NAME}
${TOP}/scratch/build/scripts/sanity.sh
if [ $isDelivery ]; then
    ${TOP}/scratch/build/aci/delivery.sh
fi

