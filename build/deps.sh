#!/bin/sh
set -xe

# build freetype (fontconfig relies on it)
cd /opt/dep 
git clone --depth 1 https://github.com/freedesktop/fontconfig
cd fontconfig
meson build --buildtype=release --prefix /usr --bindir="/usr/bin" --libdir="/usr/lib"
cd build 
ninja 
ninja install

# build fontconfig
if [ ! -d fontconfig ]; then
    git clone --depth 1 https://gitlab.freedesktop.org/fontconfig/fontconfig.git
    cd fontconfig
    ./autogen.sh --sysconfdir=/etc --prefix=/usr --mandir=/usr/share/man
    make -j $(nproc) 
    make install
fi

# build x264
cd /opt/dep 
git clone --depth 1 https://code.videolan.org/videolan/x264.git 
cd x264 
./configure --cache-file=/tmp/configure.cache --enable-pic --enable-static --prefix=/usr/local --bindir="/usr/local/bin" --libdir="/usr/local/lib" && \
make -j $(nproc) && \
make install 

# build x265
cd /opt/dep 
wget -O x265.tar.bz2 https://bitbucket.org/multicoreware/x265_git/get/master.tar.bz2 
tar xjf x265.tar.bz2 
cd multicoreware*/build/linux 
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DCMAKE_ASM_NASM_FLAGS=-w-macro-params-legacy ../../source 
make -j $(nproc) 
make install 

# build vpx
cd /opt/dep 
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git 
cd libvpx 
./configure --prefix=/usr/local --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm 
make -j $(nproc) 
make install 

# build libfdk-aac
cd /opt/dep 
git clone --depth 1 https://github.com/mstorsjo/fdk-aac 
cd fdk-aac 
autoreconf -fiv 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local 
make -j $(nproc) 
make install

# build libogg
cd /opt/dep 
curl -LO http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz 
tar xzf libogg-1.3.2.tar.gz 
cd libogg-1.3.2 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local 
make -j $(nproc) 
make install

# build libopus
cd /opt/dep 
git clone --depth 1 https://github.com/xiph/opus.git 
cd opus 
./autogen.sh 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local 
make -j $(nproc) 
make install 

# build libvorbis
cd /opt/dep 
curl -LO http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz 
tar xzf libvorbis-1.3.5.tar.gz 
cd libvorbis-1.3.5 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local --with-ogg --disable-oggtest --disable-examples 
make -j $(nproc) 
make install

# build libtheora 
cd /opt/dep 
git clone --depth 1 https://github.com/xiph/theora
cd theora
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local --with-ogg --disable-examples 
make -j $(nproc) 
make install

# build libwebp
cd /opt/dep 
curl -LO http://downloads.webmproject.org/releases/webp/libwebp-1.1.0.tar.gz 
tar xzf libwebp-1.1.0.tar.gz 
cd libwebp-1.1.0 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local --disable-examples --disable-docs 
make -j $(nproc) 
make install

# build libmp3lame
cd /opt/dep 
curl -LO http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz 
tar xzf lame-3.100.tar.gz 
cd lame-3.100
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local --enable-nasm 
make -j $(nproc) 
make install

# build fridibi 
cd /opt/dep 
git clone --depth 1 https://github.com/fribidi/fribidi 
cd fribidi 
meson build --buildtype=release -Ddocs=false --prefix /usr/local --bindir="/usr/local/bin" --libdir="/usr/local/lib"
cd build 
ninja 
ninja install

# graphite2
cd /opt/dep 
curl -LO https://github.com/silnrsi/graphite/releases/download/1.3.14/graphite2-1.3.14.tgz 
tar xzf graphite2-1.3.14.tgz 
cd graphite2-1.3.14 
mkdir build 
cd build 
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local .. 
make -j $(nproc) 
make install

# build harfbuzz
cd /opt/dep 
curl -LO https://github.com/harfbuzz/harfbuzz/releases/download/4.4.1/harfbuzz-4.4.1.tar.xz 
tar xJf harfbuzz-4.4.1.tar.xz 
cd harfbuzz-4.4.1 
meson build --buildtype=release -Dgraphite2=enabled --prefix /usr/local --bindir="/usr/local/bin" --libdir="/usr/local/lib"
cd build 
ninja 
ninja install

# build libass
cd /opt/dep 
git clone --depth 1 https://github.com/libass/libass 
cd libass 
./autogen.sh 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local 
make -j $(nproc) 
make install

# build kvazaar
cd /opt/dep 
git clone --depth 1 https://github.com/ultravideo/kvazaar 
cd kvazaar 
./autogen.sh 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local 
make -j $(nproc) 
make install

# build libaom
cd /opt/dep 
git clone --depth 1 https://aomedia.googlesource.com/aom 
mkdir aom_build 
cd aom_build 
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DENABLE_TESTS=OFF -DENABLE_NASM=on ../aom 
make -j $(nproc) 
make install

# build opencore-amr
cd /opt/dep 
curl -LO https://versaweb.dl.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-0.1.5.tar.gz 
tar xzf opencore-amr-0.1.5.tar.gz 
cd opencore-amr-0.1.5 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local 
make -j $(nproc) 
make install

# build libsvtav1
cd /opt/dep 
git clone --depth 1 https://gitlab.com/AOMediaCodec/SVT-AV1.git 
mkdir -p SVT-AV1/build 
cd SVT-AV1/build 
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF  ../../SVT-AV1 
make -j $(nproc) 
make install

# build libvmaf
cd /opt/dep 
git clone --depth 1 https://github.com/Netflix/vmaf 
cd vmaf/libvmaf 
meson build -Denable_tests=false -Denable_docs=false --buildtype=release --prefix /usr/local --bindir="/usr/local/bin" --libdir="/usr/local/lib"
cd build 
ninja 
ninja install

# build libsndfile
cd /opt/dep 
git clone --depth 1 https://github.com/libsndfile/libsndfile.git 
cd libsndfile 
./autogen.sh 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local 
make -j $(nproc) 
make install

# build xvid
cd /opt/dep 
curl -LO http://downloads.xvid.org/downloads/xvidcore-1.3.4.tar.gz 
tar xzf xvidcore-1.3.4.tar.gz 
cd xvidcore/build/generic 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local 
make -j $(nproc) 
make install

# build openjpeg
cd /opt/dep 
git clone --depth 1 https://github.com/uclouvain/openjpeg.git 
cd openjpeg 
mkdir build 
cd build 
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DCMAKE_BUILD_TYPE=Release ../ 
make -j $(nproc) 
make install

# build libvstab
cd /opt/dep 
git clone --depth 1 https://github.com/georgmartius/vid.stab 
cd vid.stab 
mkdir build 
cd build 
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DCMAKE_BUILD_TYPE=Release ../ 
make -j $(nproc) 
make install

# build libxml2
cd /opt/dep 
curl -LO https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.14.tar.xz 
tar xJvf libxml2-2.9.14.tar.xz   
cd libxml2-2.9.14 
./autogen.sh --prefix=/usr/local --with-ftp=no --with-http=no --with-python=no 
make -j $(nproc) 
make install

# build libbluray
cd /opt/dep 
curl -LO http://download.videolan.org/pub/videolan/libbluray/1.1.2/libbluray-1.1.2.tar.bz2 
tar xjvf libbluray-1.1.2.tar.bz2 
cd libbluray-1.1.2 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local --disable-examples --disable-bdjava-jar 
make -j $(nproc) 
make install

# build libaribb24
cd /opt/dep 
git clone --depth 1 https://github.com/nkoriyama/aribb24 
cd aribb24 
autoreconf -fiv 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local --disable-examples 
make -j $(nproc) 
make install

# build  libsdl2-dev 
cd /opt/dep 
git clone --depth 1 https://github.com/libsdl-org/SDL 
cd SDL 
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local --disable-examples --disable-sdl-image --disable-sdl-ttf --disable-sdl-mixer --disable-sdl-net 
make -j $(nproc) 
make install

# zimg
cd /opt/dep 
git clone https://github.com/sekrit-twc/zimg.git 
cd zimg 
# 2022.06.24 per MABS, commits after ths one break, cpuinfo broken
git checkout c9a15ec4f86adfef6c7cede8dae79762d34f2564 
./autogen.sh &&\
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local 
make -j$(nproc) 
make install 

# libdevil
cd /opt/dep
wget http://downloads.sourceforge.net/openil/DevIL-1.8.0.tar.gz
tar xvzf DevIL-1.8.0.tar.gz
cd DevIL/DevIL/
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DCMAKE_BUILD_TYPE=Release ../
make -j $(nproc)
make install
wait