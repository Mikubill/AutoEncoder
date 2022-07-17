#!/bin/sh
set -xe

cd /opt/dep 
wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip 
unzip ${OPENCV_VERSION}.zip 
rm -rf ${OPENCV_VERSION}.zip 
mkdir -p /opt/dep/opencv-${OPENCV_VERSION}/build 
cd /opt/dep/opencv-${OPENCV_VERSION}/build 
cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D BUILD_EXAMPLES=NO \
    -D WITH_FFMPEG=NO \
    -D WITH_IPP=NO \
    -D WITH_OPENEXR=NO \
    -D WITH_TBB=NO \
    -D BUILD_ANDROID_EXAMPLES=NO \
    -D INSTALL_PYTHON_EXAMPLES=NO \
    -D BUILD_DOCS=NO \
.. 
make -j $(nproc) 
make install 