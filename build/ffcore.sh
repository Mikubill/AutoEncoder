#!/bin/sh
set -xe

cd /opt/dep 
ldconfig
wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar -xjf ffmpeg-snapshot.tar.bz2 
cd ffmpeg 
./configure --prefix=/usr/local \
    --disable-debug \
    --disable-doc \
    --disable-ffplay \
    --enable-version3 \
    --enable-shared \
    --enable-gpl \
    --enable-libass \
    --enable-fontconfig \
    --enable-libfreetype \
    --enable-libvidstab \
    --enable-libxcb \
    --enable-nonfree \
    --enable-libbluray \
    --enable-libfdk-aac \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libaom \
    --enable-libwebp \
    --enable-libsvtav1 \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libvmaf 
make -j $(nproc) 
make install 