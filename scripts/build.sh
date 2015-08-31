#!/bin/sh -x

#get script location
SCRIPTDIR=`dirname $0`
SCRIPTDIR=`(cd $SCRIPTDIR ; pwd)`
#get working directory
TOP=`pwd`

#include configuration
. $SCRIPTDIR/variant.sh

# define version
VERSION=`date +%Y%m%d-%H%M%S`-`cat ${SCRIPTDIR}/../version`
VERSION_MSG="$VERSION build on "`uname -n`" by "`whoami`

# define target name
TARGET=arm-v7-linux-uclibceabi

# default value for JOBNB
if [ ! "$JOBNB" ] ; then
    JOBNB=1
fi

#create build and install dir
rm -Rf ${TOP}/build
rm -Rf ${TOP}/install
rm -Rf ${TOP}/sysroot
rm -Rf ${TOP}/out
mkdir -p ${TOP}/build/gmp
mkdir -p ${TOP}/build/mpfr
mkdir -p ${TOP}/build/mpc
mkdir -p ${TOP}/build/binutils
mkdir -p ${TOP}/build/gcc1
mkdir -p ${TOP}/build/kernelheader
mkdir -p ${TOP}/build/uclibc
mkdir -p ${TOP}/build/gcc2
mkdir -p ${TOP}/build/gdb
mkdir -p ${TOP}/build/gdbserver
mkdir ${TOP}/install
mkdir ${TOP}/install/sysroot
mkdir ${TOP}/out

#compilation options
if [ ! "$DEBUG" ] ; then
    CFLAGS_TOOLSET='-O2'
    CFLAGS_TARGET='-Os -mthumb'
else
    CFLAGS_TOOLSET='-O0 -g'
    CFLAGS_TARGET='-O1 -g -mthumb'
fi
if [ "`echo $CFLAGS_TOOLSET | grep '\-m32'`" ]; then
    ABI=32
fi

#######################################################################################################
##binutils
cd ${TOP}/build/binutils
CFLAGS=$CFLAGS_TOOLSET ${SCRIPTDIR}/../binutils/configure   --target=${TARGET} \
                                                            --prefix=${TOP}/install \
                                                            --enable-poison-system-directories \
                                                            --disable-nls \
                                                            --with-sysroot=${TOP}/install/sysroot \
                                                            --with-pkgversion="${VERSION_MSG}" \
                                                            --without-bugurl \
                                                            --disable-werror
make all -j${JOBNB}
make install

#######################################################################################################
#gmp
cd ${TOP}/build/gmp
CFLAGS=$CFLAGS_TOOLSET ${SCRIPTDIR}/../gmp/configure        --prefix=${TOP}/install_host \
                                                            --enable-cxx \
                                                            --disable-shared
make all -j${JOBNB}
make install

#######################################################################################################
#mpfr
cd ${TOP}/build/mpfr
CFLAGS=$CFLAGS_TOOLSET ${SCRIPTDIR}/../mpfr/configure       --prefix=${TOP}/install_host \
                                                            --with-gmp=${TOP}/install_host \
                                                            --disable-shared
make all -j${JOBNB}
make install

#######################################################################################################
#mpc
cd ${TOP}/build/mpc
CFLAGS=$CFLAGS_TOOLSET ${SCRIPTDIR}/../mpc/configure        --prefix=${TOP}/install_host \
                                                            --with-gmp=${TOP}/install_host \
                                                            --with-mpfr=${TOP}/install_host \
                                                            --disable-shared
make all -j${JOBNB}
make install

#######################################################################################################
#gcc1
cd ${TOP}/build/gcc1
CFLAGS=$CFLAGS_TOOLSET CFLAGS_FOR_TARGET=$CFLAGS_TARGET CXXFLAGS_FOR_TARGET=$CFLAGS_TARGET ${SCRIPTDIR}/../gcc/configure \
                                                            --prefix=${TOP}/install \
                                                            --target=${TARGET} \
                                                            --with-gmp=${TOP}/install_host \
                                                            --with-mpfr=${TOP}/install_host \
                                                            --with-mpc=${TOP}/install_host \
                                                            --without-headers \
                                                            --with-newlib \
                                                            --disable-shared \
                                                            --disable-threads \
                                                            --disable-libssp \
                                                            --disable-libgomp \
                                                            --disable-libmudflap \
                                                            --enable-languages=c \
                                                            --disable-libquadmath \
                                                            --disable-multilib \
                                                            --with-arch=${SUBARCH} \
                                                            --without-cloog \
                                                            --without-ppl \
                                                            --disable-nls

make all -j${JOBNB}
make install

#######################################################################################################
#kernel headers
cd ${TOP}/build/kernelheader
 #copy kernel source tree
cp -Rf ${SCRIPTDIR}/../kernel/* .
 #build and install
make headers_install ARCH=arm INSTALL_HDR_PATH=${TOP}/install/sysroot/usr CROSS_COMPILE=${TARGET}-

#######################################################################################################
#uclibc
cd ${TOP}/build/uclibc
 #copy and generate .config
cp -Rf ${SCRIPTDIR}/../uclibc/* .
if [ ! "$DEBUG" ] ; then
    sed "s;__KERNEL_HEADERS__;${TOP}/install/sysroot/usr/include;g" config_template | \
    sed "s;__CROSS_COMPILER_PREFIX__;${TARGET}-;g" | \
    sed "s;__DODEBUG__;# DODEBUG is not set;g" | \
    sed "s;# COMPILE_IN_THUMB_MODE is not set;COMPILE_IN_THUMB_MODE=y;g" | \
    sed "s;__DOSTRIP__;# DOSTRIP is not set;g" > .config
else
    sed "s;__KERNEL_HEADERS__;${TOP}/install/sysroot/usr/include;g" config_template | \
    sed "s;__CROSS_COMPILER_PREFIX__;${TARGET}-;g" | \
    sed "s;__DODEBUG__;DODEBUG=y;g" | \
    sed "s;# COMPILE_IN_THUMB_MODE is not set;COMPILE_IN_THUMB_MODE=y;g" | \
    sed "s;__DOSTRIP__;# DOSTRIP is not set;g" > .config
fi
PATH=${TOP}/install/bin:${PATH} make all -j${JOBNB}
PATH=${TOP}/install/bin:${PATH} make PREFIX=${TOP}/install/sysroot install

#######################################################################################################
#gcc2
cd ${TOP}/build/gcc2
CFLAGS=$CFLAGS_TOOLSET CFLAGS_FOR_TARGET=$CFLAGS_TARGET CXXFLAGS_FOR_TARGET=$CFLAGS_TARGET ${SCRIPTDIR}/../gcc/configure \
                                                            --prefix=${TOP}/install \
                                                            --target=${TARGET} \
                                                            --with-gmp=${TOP}/install_host \
                                                            --with-mpfr=${TOP}/install_host \
                                                            --with-mpc=${TOP}/install_host \
                                                            --with-sysroot=${TOP}/install/sysroot \
                                                            --disable-libgomp \
                                                            --enable-libmudflap \
                                                            --enable-languages=c,c++ \
                                                            --disable-libquadmath \
                                                            --disable-multilib \
                                                            --disable-libstdcxx-pch \
                                                            --enable-threads=posix \
                                                            --with-arch=${SUBARCH} \
                                                            --without-cloog \
                                                            --without-ppl \
                                                            --disable-nls \
                                                            --enable-libstdcxx-time \
                                                            --with-pkgversion="${VERSION_MSG}" \
                                                            --without-bugurl
make all -j${JOBNB}
make install

#######################################################################################################
#gdb
cd ${TOP}/build/gdb
CFLAGS="$CFLAGS_TOOLSET -static" ${SCRIPTDIR}/../gdb/configure  --prefix=${TOP}/install \
                                                                --target=${TARGET} \
                                                                --with-sysroot=${TOP}/install/sysroot \
                                                                --with-pkgversion="${VERSION_MSG}" \
                                                                --without-bugurl \
                                                                --disable-werror
make all -j${JOBNB}
make install

#######################################################################################################
#generate tarball
cd ${TOP}
if [ "$STRIP" ] ; then
    WDIR=`mktemp -d` && trap "rm -Rf $WDIR" EXIT
    tar -C install --atime-preserve -cf - . | tar --atime-preserve -xf - -C $WDIR
    find $WDIR -type f -exec strip -p {} \; > /dev/null 2>&1
    find $WDIR -exec install/bin/${TARGET}-strip -p {} \; > /dev/null 2>&1
    tar -C $WDIR --atime-preserve -czf out/toolset-${VERSION}-${SUBARCH}.tgz .
else
    tar -C install --atime-preserve -czf out/toolset-${VERSION}-${SUBARCH}.tgz .
fi

