#!/bin/sh
set -xe

cd /opt/vs 
git clone --depth 1 https://github.com/vapoursynth/vapoursynth.git 
cd vapoursynth
./autogen.sh 
ARCH=$(uname -m)
# bypass if arch is aarch64
if [ "${ARCH}" == "aarch64" ]; then
    ./configure --prefix=/usr/local CFLAGS="-mno-outline-atomics" CXXFLAGS="-mno-outline-atomics" 
else 
    ./configure --prefix=/usr/local 
fi 
make -j$(nproc) 
make install

# expr: avisynth
cd /opt/avs 
git clone --depth 1 https://github.com/AviSynth/AviSynthPlus.git  
cd AviSynthPlus 
mkdir build 
cd build 
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. -G Ninja
ninja
ninja install 