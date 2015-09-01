#!/bin/sh -x

#get script location
SCRIPTDIR=`dirname $0`
SCRIPTDIR=`(cd $SCRIPTDIR ; pwd)`
#get working directory
TOP=`pwd`

#temporary directory
WDIR=`mktemp -d` && trap "rm -Rf $WDIR" EXIT

#untar toolset and runtime
cd ${WDIR}
tar xf ${TOP}/out/toolset-*
tar xf ${TOP}/out/runtime-*

#generate test.c
cat << EOF > test.c
int main(int argc, char **argv)
{
    return 0;
}
EOF

#build it
./bin/arm-v7-linux-uclibceabi-gcc test.c -o test

#run it
./proot -R rootfs -q ./qemu-arm ./test

