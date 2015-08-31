#!/bin/sh -ex

#get script location
SCRIPTDIR=`dirname $0`
SCRIPTDIR=`(cd $SCRIPTDIR ; pwd)`
#get working directory
TOP=`pwd`

#copy with update
#gmp
cp -Ru ${TOP}/scratch/gmp/* ${TOP}/src/gmp
#mpfr
cp -Ru ${TOP}/scratch/mpfr/* ${TOP}/src/mpfr
#mpc
cp -Ru ${TOP}/scratch/mpc/* ${TOP}/src/mpc
#binutils
cp -Ru ${TOP}/scratch/binutils/* ${TOP}/src/binutils
#gcc
cp -Ru ${TOP}/scratch/gcc/* ${TOP}/src/gcc
#kernel
cp -Ru ${TOP}/scratch/kernel/* ${TOP}/src/kernel
cp -RuL ${TOP}/scratch/kernel/.git ${TOP}/src/kernel/ || true
#uclibc
cp -Ru ${TOP}/scratch/uclibc/* ${TOP}/src/uclibc
#gdb
cp -Ru ${TOP}/scratch/gdb/* ${TOP}/src/gdb
#scripts
cp -Ru ${TOP}/scratch/build/scripts ${TOP}/src
cp -Ru ${TOP}/scratch/variant/* ${TOP}/src/scripts
#add version file
cd ${TOP}/.repo/manifests
VERSION=`git describe --always --dirty --tags --long --abbrev=8 2>/dev/null`
echo ${VERSION} > ${TOP}/src/version

