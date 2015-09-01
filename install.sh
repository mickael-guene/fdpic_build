#!/bin/sh -ex

#get script location
SCRIPTDIR=`dirname $0`
SCRIPTDIR=`(cd $SCRIPTDIR ; pwd)`
#get working directory
TOP=`pwd`

#clean up thinks
rm -Rf ${TOP}/src
mkdir -p ${TOP}/src/binutils
mkdir -p ${TOP}/src/gcc
mkdir -p ${TOP}/src/gmp
mkdir -p ${TOP}/src/mpfr
mkdir -p ${TOP}/src/mpc
mkdir -p ${TOP}/src/kernel
mkdir -p ${TOP}/src/uclibc
mkdir -p ${TOP}/src/gdb
mkdir -p ${TOP}/src/qemu

# copy directory
#gmp
cp -Rf ${TOP}/scratch/gmp/* ${TOP}/src/gmp
#mpfr
cp -Rf ${TOP}/scratch/mpfr/* ${TOP}/src/mpfr
#mpc
cp -Rf ${TOP}/scratch/mpc/* ${TOP}/src/mpc
#binutils
cp -Rf ${TOP}/scratch/binutils/* ${TOP}/src/binutils
#gcc
cp -Rf ${TOP}/scratch/gcc/* ${TOP}/src/gcc
#kernel
cp -Rf ${TOP}/scratch/kernel/* ${TOP}/src/kernel
cp -RfL ${TOP}/scratch/kernel/.git ${TOP}/src/kernel/ || true
#uclibc
cp -Rf ${TOP}/scratch/uclibc/* ${TOP}/src/uclibc
#gdb
cp -Rf ${TOP}/scratch/gdb/* ${TOP}/src/gdb
#qemu
cp -Rf ${TOP}/scratch/qemu/* ${TOP}/src/qemu
#scripts
cp -Rf ${TOP}/scratch/build/scripts ${TOP}/src
cp -Rf ${TOP}/scratch/variant/* ${TOP}/src/scripts
#add version file
cd ${TOP}/.repo/manifests
VERSION=`git describe --always --dirty --tags --long --abbrev=8 2>/dev/null`
echo ${VERSION} > ${TOP}/src/version

