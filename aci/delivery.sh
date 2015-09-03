#!/bin/sh -ex

#get script location
SCRIPTDIR=`dirname $0`
SCRIPTDIR=`(cd $SCRIPTDIR ; pwd)`
#get working directory
TOP=`pwd`

# define version
cd ${TOP}/.repo/manifests
TAG_NAME=`git describe --tags --always 2>/dev/null`
cd ${TOP}
# push packages
for f in ${TOP}/out/* ; do
    python ${TOP}/scratch/build/aci/upload_release.py -u mickael-guene -r fdpic_manifest -t $TAG_NAME $f
done

