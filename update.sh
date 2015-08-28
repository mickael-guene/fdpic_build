#!/bin/sh -ex

#get script location
SCRIPTDIR=`dirname $0`
SCRIPTDIR=`(cd $SCRIPTDIR ; pwd)`
#get working directory
TOP=`pwd`

if [ "x$WORKSPACE" = "x" ]; then
    WORKSPACE=$TOP
    MYWORKSPACE=$TOP
fi

#copy with update
#gmp
cp -Ru ${WORKSPACE}/scratch/gmp/* ${MYWORKSPACE}/src/gmp
#mpfr
cp -Ru ${WORKSPACE}/scratch/mpfr/* ${MYWORKSPACE}/src/mpfr
#mpc
cp -Ru ${WORKSPACE}/scratch/mpc/* ${MYWORKSPACE}/src/mpc
#binutils
cp -Ru ${WORKSPACE}/scratch/binutils/* ${MYWORKSPACE}/src/binutils
#gcc
cp -Ru ${WORKSPACE}/scratch/gcc/* ${MYWORKSPACE}/src/gcc
#kernel
cp -Ru ${WORKSPACE}/scratch/kernel/* ${MYWORKSPACE}/src/kernel
cp -RuL ${WORKSPACE}/scratch/kernel/.git ${MYWORKSPACE}/src/kernel/ || true
#uclibc
cp -Ru ${WORKSPACE}/scratch/uclibc/* ${MYWORKSPACE}/src/uclibc
#gdb
cp -Ru ${WORKSPACE}/scratch/gdb/* ${MYWORKSPACE}/src/gdb
#scripts
cp -Ru ${WORKSPACE}/scratch/build/scripts ${MYWORKSPACE}/src
cp -Ru ${WORKSPACE}/scratch/variant/* ${MYWORKSPACE}/src/scripts
#add version file
cd ${WORKSPACE}/.repo/manifests
VERSION=`git describe --always --dirty --tags --long --abbrev=8 2>/dev/null`
echo ${VERSION} > ${MYWORKSPACE}/src/version

