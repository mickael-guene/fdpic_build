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

#clean up thinks
rm -Rf ${MYWORKSPACE}/src
mkdir -p ${MYWORKSPACE}/src/binutils
mkdir -p ${MYWORKSPACE}/src/gcc
mkdir -p ${MYWORKSPACE}/src/gmp
mkdir -p ${MYWORKSPACE}/src/mpfr
mkdir -p ${MYWORKSPACE}/src/mpc
mkdir -p ${MYWORKSPACE}/src/kernel
mkdir -p ${MYWORKSPACE}/src/uclibc
mkdir -p ${MYWORKSPACE}/src/gdb

# copy directory
#gmp
cp -Rf ${WORKSPACE}/scratch/gmp/* ${MYWORKSPACE}/src/gmp
#mpfr
cp -Rf ${WORKSPACE}/scratch/mpfr/* ${MYWORKSPACE}/src/mpfr
#mpc
cp -Rf ${WORKSPACE}/scratch/mpc/* ${MYWORKSPACE}/src/mpc
#binutils
cp -Rf ${WORKSPACE}/scratch/binutils/* ${MYWORKSPACE}/src/binutils
#gcc
cp -Rf ${WORKSPACE}/scratch/gcc/* ${MYWORKSPACE}/src/gcc
#kernel
cp -Rf ${WORKSPACE}/scratch/kernel/* ${MYWORKSPACE}/src/kernel
cp -RfL ${WORKSPACE}/scratch/kernel/.git ${MYWORKSPACE}/src/kernel/ || true
#uclibc
cp -Rf ${WORKSPACE}/scratch/uclibc/* ${MYWORKSPACE}/src/uclibc
#gdb
cp -Rf ${WORKSPACE}/scratch/gdb/* ${MYWORKSPACE}/src/gdb
#scripts
cp -Rf ${WORKSPACE}/scratch/build/scripts ${MYWORKSPACE}/src
cp -Rf ${WORKSPACE}/scratch/variant/* ${MYWORKSPACE}/src/scripts
#add version file
cd ${WORKSPACE}/.repo/manifests
VERSION=`git describe --always --dirty --tags --long --abbrev=8 2>/dev/null`
echo ${VERSION} > ${MYWORKSPACE}/src/version

