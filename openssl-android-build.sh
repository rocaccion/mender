#!/bin/bash

TOOLCHAIN="aarch64-linux-android"
CONFIGURE_PLATFORM="linux-generic64 -DB_ENDIAN"

PATH_ORG=$PATH
OUTPUT_DIR=$OPENSSL_INSTALL_PATH

# Set toolchain
TOOLCHAIN_ROOT=$NDK_ROOT
SYSROOT=$TOOLCHAIN_ROOT/sysroot
CC=$NDK_ROOT/bin/aarch64-linux-android29-clang
CXX=$NDK_ROOT/bin/aarch64-linux-android29-clang++
AR=$TOOLCHAIN-ar
AS=$TOOLCHAIN-as
LD=$TOOLCHAIN-ld
RANLIB=$TOOLCHAIN-ranlib
NM=$TOOLCHAIN-nm
STRIP=$TOOLCHAIN-strip
CHOST=$TOOLCHAIN
CXXFLAGS="-std=c++11 -fPIC"
CPPFLAGS="-DANDROID -fPIC"
PATH=$PATH_ORG:$TOOLCHAIN_ROOT/bin:$SYSROOT/usr/local/bin

# Clean output:
rm -rf $OPENSSL_INSTALL_PATH

mkdir $OPENSSL_INSTALL_PATH/lib
cd $OPENSSL_PATH

# Clean openssl:	
/usr/bin/make clean

# Build openssl libraries
perl -pi -w -e 's/\-mandroid//g;' ./Configure
./Configure $CONFIGURE_PLATFORM shared threads no-asm no-sse2

# patch SONAME
perl -pi -e 's/SHLIB_EXT=\.so\.\$\(SHLIB_MAJOR\)\.\$\(SHLIB_MINOR\)/SHLIB_EXT=\.so/g' Makefile
perl -pi -e 's/SHARED_LIBS_LINK_EXTS=\.so\.\$\(SHLIB_MAJOR\) \.so//g' Makefile
# quote injection for proper SONAME
perl -pi -e 's/SHLIB_MAJOR=1/SHLIB_MAJOR=`/g' Makefile
perl -pi -e 's/SHLIB_MINOR=0.0/SHLIB_MINOR=`/g' Makefile

/usr/bin/make build_libs -j8
mkdir -p $OPENSSL_INSTALL_PATH

#file libcrypto.so
#file libssl.so

cp $OPENSSL_PATH/libcrypto.a $OPENSSL_INSTALL_PATH/libcrypto.a
cp $OPENSSL_PATH/libssl.a $OPENSSL_INSTALL_PATH/libssl.a
cp $OPENSSL_PATH/libcrypto.so $OPENSSL_INSTALL_PATH/libcrypto.so
cp $OPENSSL_PATH/libssl.so $OPENSSL_INSTALL_PATH/libssl.so


export PATH=$PATH_ORG
