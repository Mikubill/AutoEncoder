#!/bin/sh
set -xe

# recompile x264, x265, vpx

# build x264
cd /opt/dep/x264 
make clean
./configure --cache-file=/tmp/configure.cache --enable-pic --enable-static --prefix=/usr/local --bindir="/usr/local/bin" --libdir="/usr/local/lib"
make -j $(nproc) 
make install

# build x265
cd /opt/dep/multicoreware*/build/linux 
make clean
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DCMAKE_ASM_NASM_FLAGS=-w-macro-params-legacy ../../source 
make -j $(nproc) 
make install 

# build vpx
cd /opt/dep/libvpx 
make clean
./configure --prefix=/usr/local --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm 
make -j $(nproc) 
make install 