#!/bin/bash
export GOPATH=~/mender
export NDK_ROOT=~/ndk-dir
export LIBLZMA_INSTALL_PATH=$GOPATH/src/github.com/mendersoftware/mender/xz-5.2.4/install
/usr/bin/make -f $GOPATH/src/github.com/mendersoftware/mender/Makefile build GOOS=android GOARCH=arm64 CGO_ENABLED=1 CC=$NDK_ROOT/bin/aarch64-linux-android29-clang CXX=$NDK_ROOT/bin/aarch64-linux-android29-clang++ CGO_CFLAGS="-Wno-implicit-fallthrough -DMDB_USE_POSIX_MUTEX -DMDB_USE_ROBUST=0 -I${LIBLZMA_INSTALL_PATH}/include" CGO_LDFLAGS="-L${LIBLZMA_INSTALL_PATH}/lib"
