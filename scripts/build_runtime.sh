#!/bin/sh -x

#get script location
SCRIPTDIR=`dirname $0`
SCRIPTDIR=`(cd $SCRIPTDIR ; pwd)`
#get working directory
TOP=`pwd`
isDelivery=`echo $1 | grep delivery` || true

#include configuration
. $SCRIPTDIR/variant.sh

# define version
if [ ! "$isDelivery" ] ; then
    VERSION=`date +%Y%m%d-%H%M%S`-`cat ${SCRIPTDIR}/../version`
else
    VERSION=`cat ${SCRIPTDIR}/../version`
fi
VERSION_MSG="$VERSION build on "`uname -n`" by "`whoami`

# define target name
TARGET=arm-v7-linux-uclibceabi

# default value for JOBNB
if [ ! "$JOBNB" ] ; then
    JOBNB=1
fi

#compilation options
if [ ! "$DEBUG" ] ; then
    CFLAGS_TOOLSET='-O2'
    CFLAGS_TARGET='-Os -mthumb'
else
    CFLAGS_TOOLSET='-O0 -g'
    CFLAGS_TARGET='-O1 -g -mthumb'
fi

#create build and install dir
rm ${TOP}/out/runtime-*
rm -Rf ${TOP}/build/qemu
mkdir -p ${TOP}/build/qemu
rm -Rf ${TOP}/build/gdbserver
mkdir -p ${TOP}/build/gdbserver
rm -Rf ${TOP}/build/proot
mkdir -p ${TOP}/build/proot
rm -Rf ${TOP}/install/rootfs 
mkdir ${TOP}/install/rootfs
rm -Rf -p ${TOP}/install/tools
mkdir -p ${TOP}/install/tools/bin

#######################################################################################################
##proot
wget http://portable.proot.me/proot-x86_64 -O ${TOP}/build/proot/proot
chmod a+x ${TOP}/build/proot/proot
cp ${TOP}/build/proot/proot . ${TOP}/install/tools/bin/.

#######################################################################################################
##qemu
cd ${TOP}/build/qemu
CFLAGS="$CFLAGS_TOOLSET" ${SCRIPTDIR}/../qemu/configure     --prefix=${TOP}/install/tools \
                                                            --target-list=arm-linux-user \
                                                            --enable-fdpic \
                                                            --disable-pie \
                                                            --disable-guest-base \
                                                            --with-default-cpu-model="cortex-m3"
make all -j${JOBNB}
make install

#######################################################################################################
###gdbserver
cd ${TOP}/build/gdbserver
 #configure
PATH=${TOP}/install/bin:${PATH} CFLAGS="$CFLAGS_TARGET -D__UCLIBC__ -DHAS_NOMMU" ${SCRIPTDIR}/../gdb/gdb/gdbserver/configure \
                                                            --prefix=${TOP}/install/rootfs \
                                                            --program-prefix="" \
                                                            --host=${TARGET} \
                                                            --target=${TARGET} \
                                                            --with-pkgversion="${VERSION_MSG}" \
                                                            --without-bugurl

 #build
PATH=${TOP}/install/bin:${PATH} make all -j${JOBNB}
 #install
make install

#######################################################################################################
##rootfs
cd ${TOP}/install/rootfs
cp -Rf ${TOP}/install/sysroot/* .
cp -RfL ${TOP}/install/${TARGET}/lib/libstdc++.so.6 lib/libstdc++.so.6
cp -Rf ${TOP}/install/${TARGET}/lib/libgcc_s.so.1 lib/libgcc_s.so.1
cp -RfL ${TOP}/install/${TARGET}/lib/libssp.so.0 lib/libssp.so.0
cp -RfL ${TOP}/install/${TARGET}/lib/libmudflap.so.0.0.0 lib/libmudflap.so.0
cp -RfL ${TOP}/install/${TARGET}/lib/libmudflapth.so.0.0.0 lib/libmudflapth.so.0

#######################################################################################################
#generate tarball
cd ${TOP}
tar cf out/runtime-${VERSION}-${SUBARCH} --exclude='*.a' --exclude='*.o' -C ${TOP}/install ./rootfs/lib ./rootfs/usr/lib ./rootfs/bin
tar rf out/runtime-${VERSION}-${SUBARCH} -C ${TOP}/install/tools/bin proot qemu-arm
gzip -S .tgz out/runtime-${VERSION}-${SUBARCH}

