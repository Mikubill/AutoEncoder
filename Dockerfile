FROM python:latest as env

ENV WORKDIR='/opt'
ENV LD_LIBRARY_PATH='/usr/local/lib'
ENV LIBRARY_PATH='/usr/local/lib'
ENV PKG_CONFIG_PATH='/usr/local/lib/pkgconfig'
ENV PYTHONPATH='/usr/local/lib/python3.10/site-packages'
ENV CXXFLAGS="$CXXFLAGS -fPIC"
ENV CFLAGS="$CFLAGS -fPIC"

WORKDIR ${WORKDIR}

# install apt-fast
RUN apt update && \
    apt upgrade -y

# Development dependencies
RUN apt install -y build-essential autoconf autogen automake autotools-dev libtool pkg-config curl git xz-utils && \
    apt install -y yasm nasm cmake xxd &&\
    # ffmpeg dependencies
    apt install -y libgnutls28-dev libva-dev libunistring-dev fontconfig libnuma-dev libdevil-dev && \
    apt install -y libxcb-shm0-dev libxcb-xfixes0-dev libvdpau-dev libvorbis-dev libxcb1-dev libdav1d-dev &&\
    # eedi2&eedi3 depend on opencl and boost
    apt install -y ocl-icd-opencl-dev libboost-all-dev && \
    # python build tools
    pip install --upgrade wheel meson cpython cython pip ninja && \
    mkdir -p /opt/dep /opt/vs /opt/avs 

# build x264
RUN cd /opt/dep && \
    git clone --depth 1 https://code.videolan.org/videolan/x264.git && \
    cd x264 && \
    ./configure --enable-pic --enable-static --prefix=/usr/local --bindir="/usr/local/bin" && \
    make -j $(nproc) && \
    make install 

# build x265
RUN cd /opt/dep && \
    wget -O x265.tar.bz2 https://bitbucket.org/multicoreware/x265_git/get/master.tar.bz2 && \
    tar xjf x265.tar.bz2 && \
    cd multicoreware*/build/linux && \
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DCMAKE_ASM_NASM_FLAGS=-w-macro-params-legacy ../../source && \
    make -j $(nproc) && \
    make install 

# build vpx
RUN cd /opt/dep && \
    git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && \
    cd libvpx && \
    ./configure --prefix=/usr/local --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && \
    make -j $(nproc) && \
    make install 

# build libfdk-aac
RUN cd /opt/dep && \
    git clone --depth 1 https://github.com/mstorsjo/fdk-aac && \
    cd fdk-aac && \
    autoreconf -fiv && \
    ./configure --prefix=/usr/local && \
    make -j $(nproc) && \
    make install

# build libogg
RUN cd /opt/dep && \
    curl -LO http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz && \
    tar xzf libogg-1.3.2.tar.gz && \
    cd libogg-1.3.2 && \
    ./configure --prefix=/usr/local && \
    make -j $(nproc) && \
    make install

# build libopus
RUN cd /opt/dep && \
    git clone --depth 1 https://github.com/xiph/opus.git && \
    cd opus && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j $(nproc) && \
    make install 

# build libvorbis
RUN cd /opt/dep && \
    curl -LO http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz && \
    tar xzf libvorbis-1.3.5.tar.gz && \
    cd libvorbis-1.3.5 && \
    ./configure --prefix=/usr/local --with-ogg --disable-oggtest --disable-examples && \
    make -j $(nproc) && \
    make install

# build libtheora 
RUN cd /opt/dep && \
    curl -LO http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2 && \
    tar xjf libtheora-1.1.1.tar.bz2 && \
    cd libtheora-1.1.1 && \
    ./configure --prefix=/usr/local --with-ogg --disable-examples && \
    make -j $(nproc) && \
    make install

# build libwebp
RUN cd /opt/dep && \
    curl -LO http://downloads.webmproject.org/releases/webp/libwebp-1.1.0.tar.gz && \
    tar xzf libwebp-1.1.0.tar.gz && \
    cd libwebp-1.1.0 && \
    ./configure --prefix=/usr/local --disable-examples --disable-docs && \
    make -j $(nproc) && \
    make install

# build libmp3lame
RUN cd /opt/dep && \
    curl -LO http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz && \
    tar xzf lame-3.99.5.tar.gz && \
    cd lame-3.99.5 && \
    ./configure --prefix=/usr/local --enable-nasm && \
    make -j $(nproc) && \
    make install

# build fridibi 
RUN cd /opt/dep && \
    git clone https://github.com/fribidi/fribidi && \
    cd fribidi && \
    meson build --buildtype=release -Ddocs=false --prefix /usr/local --bindir="/usr/local/bin" --libdir="/usr/local/lib" && \
    cd build && \
    ninja && \
    ninja install

# build freetype
RUN cd /opt/dep && \
    curl -LO http://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz && \
    tar zxf freetype-2.9.tar.gz && \
    cd freetype-2.9 && \
    ./configure --prefix=/usr/local && \
    make -j $(nproc) && \
    make install

# graphite2
RUN cd /opt/dep && \
    curl -LO https://github.com/silnrsi/graphite/releases/download/1.3.14/graphite2-1.3.14.tgz && \
    tar xzf graphite2-1.3.14.tgz && \
    cd graphite2-1.3.14 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local .. && \
    make -j $(nproc) && \
    make install

# build harfbuzz
RUN cd /opt/dep && \
    curl -LO https://github.com/harfbuzz/harfbuzz/releases/download/4.4.1/harfbuzz-4.4.1.tar.xz && \
    tar xJf harfbuzz-4.4.1.tar.xz && \
    cd harfbuzz-4.4.1 && \
    meson build --buildtype=release -Dgraphite2=enabled --prefix /usr/local --bindir="/usr/local/bin" --libdir="/usr/local/lib" && \
    cd build && \
    ninja && \
    ninja install

# build libass
RUN cd /opt/dep && \
    git clone --depth 1 https://github.com/libass/libass && \
    cd libass && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j $(nproc) && \
    make install

# build kvazaar
RUN cd /opt/dep && \
    git clone --depth 1 https://github.com/ultravideo/kvazaar && \
    cd kvazaar && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j $(nproc) && \
    make install
    
# build libaom
RUN cd /opt/dep && \
    git clone --depth 1 https://aomedia.googlesource.com/aom && \
    mkdir aom_build && \
    cd aom_build && \
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DENABLE_TESTS=OFF -DENABLE_NASM=on ../aom && \
    make -j $(nproc) && \
    make install

# build opencore-amr
RUN cd /opt/dep && \
    curl -LO https://versaweb.dl.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-0.1.5.tar.gz && \
    tar xzf opencore-amr-0.1.5.tar.gz && \
    cd opencore-amr-0.1.5 && \
    ./configure --prefix=/usr/local && \
    make -j $(nproc) && \
    make install

# build libsvtav1
RUN cd /opt/dep && \
    git clone --depth 1 https://gitlab.com/AOMediaCodec/SVT-AV1.git && \
    mkdir -p SVT-AV1/build && \
    cd SVT-AV1/build && \
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF --libdir="/usr/local/lib"  ../../SVT-AV1 && \
    make -j $(nproc) && \
    make install

# build libvmaf
RUN cd /opt/dep && \
    git clone --depth 1 https://github.com/Netflix/vmaf && \
    cd vmaf/libvmaf && \
    meson build -Denable_tests=false -Denable_docs=false --buildtype=release --prefix /usr/local --bindir="/usr/local/bin" --libdir="/usr/local/lib" && \
    cd build && \
    ninja && \
    ninja install

# build libsndfile
RUN cd /opt/dep && \
    git clone https://github.com/libsndfile/libsndfile.git && \
    cd libsndfile && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j $(nproc) && \
    make install

# build xvid
RUN cd /opt/dep && \
    curl -LO http://downloads.xvid.org/downloads/xvidcore-1.3.4.tar.gz && \
    tar xzf xvidcore-1.3.4.tar.gz && \
    cd xvidcore/build/generic && \
    ./configure --prefix=/usr/local && \
    make -j $(nproc) && \
    make install

# build openjpeg
RUN cd /opt/dep && \
    git clone https://github.com/uclouvain/openjpeg.git && \
    cd openjpeg && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DCMAKE_BUILD_TYPE=Release ../ && \
    make -j $(nproc) && \
    make install

# build libvstab
RUN cd /opt/dep && \
    git clone https://github.com/georgmartius/vid.stab && \
    cd vid.stab && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DCMAKE_BUILD_TYPE=Release ../ && \
    make -j $(nproc) && \
    make install

# build libxml2
RUN cd /opt/dep && \
    curl -LO https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.14.tar.xz && \
    tar xJf libxml2-2.9.14.tar.xz && \  
    cd libxml2-2.9.14 && \
    ./autogen.sh --prefix=/usr/local --with-ftp=no --with-http=no --with-python=no && \
    make -j $(nproc) && \
    make install

# build libbluray
RUN cd /opt/dep && \
    curl -LO http://download.videolan.org/pub/videolan/libbluray/1.1.2/libbluray-1.1.2.tar.bz2 && \
    tar xjf libbluray-1.1.2.tar.bz2 && \
    cd libbluray-1.1.2 && \
    ./configure --prefix=/usr/local --disable-examples --disable-bdjava-jar && \
    make -j $(nproc) && \
    make install

# build libaribb24
RUN cd /opt/dep && \
    git clone https://github.com/nkoriyama/aribb24 && \
    cd aribb24 && \
    autoreconf -fiv && \
    ./configure --prefix=/usr/local --disable-examples && \
    make -j $(nproc) && \
    make install

# build  libsdl2-dev 
RUN cd /opt/dep && \
    git clone https://github.com/libsdl-org/SDL && \
    cd SDL && \
    ./configure --prefix=/usr/local --disable-examples --disable-sdl-image --disable-sdl-ttf --disable-sdl-mixer --disable-sdl-net && \
    make -j $(nproc) && \
    make install

# zimg
RUN cd /opt/dep && \
    git clone https://github.com/sekrit-twc/zimg.git && \
    cd zimg && \
    # 2022.06.24 per MABS, commits after ths one break, cpuinfo broken
    git checkout c9a15ec4f86adfef6c7cede8dae79762d34f2564 && \
    ./autogen.sh &&\
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install 

# Vapoursynth
RUN cd /opt/vs && \
    git clone https://github.com/vapoursynth/vapoursynth.git && \
    cd vapoursynth && \
    ./autogen.sh &&\
    ./configure --prefix=/usr/local && \
    # arm only. otherwise it fails to build.
    make -j$(nproc) && \
    make install 

# expr: avisynth
RUN cd /opt/avs && \
    git clone --depth 1 https://github.com/AviSynth/AviSynthPlus.git && \
    cd AviSynthPlus && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. -G Ninja && \
    ninja && \
    ninja install

# install ffmpeg
RUN cd /opt/dep && \
    ldconfig && \
    wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
    tar -xjf ffmpeg-snapshot.tar.bz2 && \
    cd ffmpeg && \
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
        --enable-libvmaf && \
    make -j $(nproc) && \
    make install 

# OpenCV
ENV OPENCV_VERSION=4.6.0
RUN cd /opt/dep && \
    wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
    unzip ${OPENCV_VERSION}.zip && \
    rm -rf ${OPENCV_VERSION}.zip && \
    mkdir -p /opt/dep/opencv-${OPENCV_VERSION}/build && \
    cd /opt/dep/opencv-${OPENCV_VERSION}/build && \
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
    .. && \
    make -j $(nproc) && \
    make install 

# build vs-plugin: l-smash
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/l-smash/l-smash.git && \
    cd l-smash && \
    ./configure --prefix=/usr/local --enable-shared && \
    make  && \
    make install  && \
    ldconfig

# bulid vs-plugin: l-smash-works
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfAviSynthPlusEvolution/L-SMASH-Works && \
    cd L-SMASH-Works/VapourSynth && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: addgrain
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-AddGrain && \
    cd VapourSynth-AddGrain && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: subtext
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/vapoursynth/subtext && \
    cd subtext && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin awarpsharp2
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-awarpsharp2 && \
    cd vapoursynth-awarpsharp2 && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: bifrost
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-bifrost && \
    cd vapoursynth-bifrost && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install 

# build vs-plugin: builateral
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bilateral && \
    cd VapourSynth-Bilateral && \
    ./configure --install=/usr/local/lib/vapoursynth && \
    make -j$(nproc) && \
    make install

# build vs-plugin: convo2d
# RUN cd /opt/vs && \
#     git clone --depth 1 https://github.com/chikuzen/convo2d && \
#     cd convo2d && \
#     ./configure && \
#     make -j$(nproc) && \
#     make install

# build vs-plugin: cnr2
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-cnr2 && \
    cd vapoursynth-cnr2 && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install 

# build vs-plugin: combmask
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/chikuzen/CombMask && \
    cd CombMask/vapoursynth/src && \
    chmod +x configure && \
    ./configure --install=/usr/local/lib/vapoursynth && \
    make -j$(nproc) && \
    make install

# build vs-plugins: d2vsource
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dwbuiten/d2vsource && \
    cd d2vsource && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build fftw3f - with float support
RUN cd /opt/vs && \
    wget http://www.fftw.org/fftw-3.3.10.tar.gz && \
    tar -xzf fftw-3.3.10.tar.gz && \
    cd fftw-3.3.10 && \
    ./configure --prefix=/usr/local --enable-float --enable-threads --enable-shared && \
    make -j$(nproc) && \
    make install


# build vs-plugin: damb
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-damb && \
    cd vapoursynth-damb && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: dctfilter
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DCTFilter && \
    cd VapourSynth-DCTFilter && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: deblock
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Deblock  && \
    cd VapourSynth-Deblock && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: deblockpp7
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DeblockPP7 && \
    cd VapourSynth-DeblockPP7 && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: degrain-med
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-degrainmedian && \
    cd vapoursynth-degrainmedian && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: delogo
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DeLogo && \
    cd VapourSynth-DeLogo && \
    ./configure --install=/usr/local/lib/vapoursynth && \
    make -j$(nproc) && \
    make install

# build vs-plugin: bm3d
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-BM3D && \
    cd VapourSynth-BM3D && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: cas
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-CAS && \
    cd VapourSynth-CAS && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: ctmf
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-CTMF && \
    cd VapourSynth-CTMF && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: dfttest
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DFTTest && \
    cd VapourSynth-DFTTest && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: eedi2
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-EEDI2 && \
    cd VapourSynth-EEDI2 && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: eedi3
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-EEDI3 && \
    cd VapourSynth-EEDI3 && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: ffms2
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/FFMS/ffms2 && \
    cd ffms2 && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: fft3dfilter
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/myrsloik/VapourSynth-FFT3DFilter && \
    cd VapourSynth-FFT3DFilter && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: fieldhint
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-fieldhint && \
    cd vapoursynth-fieldhint && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# builds vs-plugin: fillborders
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-fillborders && \
    cd vapoursynth-fillborders && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: f3kdb
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/SAPikachu/flash3kyuu_deband && \
    cd flash3kyuu_deband && \
    ./waf configure --prefix=/usr/local && \
    ./waf build && \
    ./waf install

# build vs-plugin: fluxsmmoth
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-fluxsmooth && \
    cd vapoursynth-fluxsmooth && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: fmtconv
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/EleonoreMizo/fmtconv && \
    cd fmtconv && \
    cd ./build/unix && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install


# build vs-plugin: GenericFilters
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/myrsloik/GenericFilters && \
    cd GenericFilters && \
    cd src && \
    ./configure --install=/usr/local/lib/vapoursynth && \
    make -j$(nproc) && \
    make install

# build vs-plugin: histogram
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-histogram && \
    cd vapoursynth-histogram && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: hqdn3d
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/Hinterwaeldlers/vapoursynth-hqdn3d && \
    cd vapoursynth-hqdn3d && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# # build vs-plugin: image_reader
# RUN cd /opt/vs && \
#     git clone --depth 1 https://github.com/chikuzen/vsimagereader && \
#     cd vsimagereader/src && \
#     ./configure --prefix=/usr/local && \
#     make -j$(nproc) && \
#     make install

# build vs-plugin: it
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-IT && \
    cd VapourSynth-IT && \
    ./configure --install=/usr/local/lib/vapoursynth && \
    make -j$(nproc) && \
    make install


# build vs-plugin: knlMeansCL
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/Khanattila/KNLMeansCL && \
    cd KNLMeansCL && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: msmoosh
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-msmoosh && \
    cd vapoursynth-msmoosh && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: mvtools
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-mvtools && \
    cd vapoursynth-mvtools && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: nnedi3
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-nnedi3 && \
    cd vapoursynth-nnedi3 && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: nnedi3_cl
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-NNEDI3CL && \
    cd VapourSynth-NNEDI3CL && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# # build vs-plugin: vsrawsource
# RUN cd /opt/vs && \
#     git clone --depth 1 https://github.com/chikuzen/vsrawsource && \
#     cd vsrawsource && \
#     ./configure --prefix=/usr/local && \
#     make -j$(nproc) && \
#     make install

# build vs-plugin: read_mpls
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-ReadMpls && \
    cd VapourSynth-ReadMpls && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: reduce_flicker
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/VFR-maniac/VapourSynth-ReduceFlicker && \
    cd VapourSynth-ReduceFlicker && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: retinex
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Retinex && \
    cd VapourSynth-Retinex && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: snm
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-SangNomMod && \
    cd VapourSynth-SangNomMod && \
    ./configure --install=/usr/local/lib/vapoursynth && \
    make -j$(nproc) && \
    make install


# # build vs-plugin: screenchange
# COPY extras/screenchange-0.2.0-2 /usr/local/lib/vapoursynth

# build vs-plugin: scrawl
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-scrawl && \
    cd vapoursynth-scrawl && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: scxvid
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-scxvid && \
    cd vapoursynth-scxvid && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: ssiq
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-ssiq && \
    cd vapoursynth-ssiq && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# # build vs-plugin: tc2cfr
# RUN cd /opt/vs && \
#     git clone --depth 1 https://github.com/gnaggnoyil/tc2cfr && \
#     cd tc2cfr && \

# build vs-plugin: tcomb
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-tcomb && \
    cd vapoursynth-tcomb && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: tdm
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TDeintMod && \
    cd VapourSynth-TDeintMod && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: temporalsoften
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-temporalsoften && \
    cd vapoursynth-temporalsoften && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: TNLMeans
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/VFR-maniac/VapourSynth-TNLMeans && \
    cd VapourSynth-TNLMeans && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: ttempsmooth
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TTempSmooth && \
    cd VapourSynth-TTempSmooth && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install


# build vs-plugin: vaguedenoiser
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-VagueDenoiser && \
    cd VapourSynth-VagueDenoiser && \
    ./configure --install=/usr/local/lib/vapoursynth && \
    make -j$(nproc) && \
    make install

# build vs-plugin: videoscope
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/dubhater/vapoursynth-videoscope && \
    cd vapoursynth-videoscope && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: w3fdif
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-W3FDIF && \
    cd VapourSynth-W3FDIF && \
    ./configure --install=/usr/local/lib/vapoursynth && \
    make -j$(nproc) && \
    make install

# install waifu2x-ncnn-vulkan
# RUN cd /opt/vs && \
#     apt-get install libvulkan-dev && \
#     git clone --depth 1 https://github.com/nihui/waifu2x-ncnn-vulkan && \
#     cd waifu2x-ncnn-vulkan && \
#     git submodule update --init --recursive && \
#     mkdir build && \
#     cd build && \
#     cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local ../src && \
#     cmake --build -j$(nproc) 

# build vs-plugin: waifu2x-cc
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/DeadSix27/waifu2x-converter-cpp && \
    cd waifu2x-converter-cpp && \
    mkdir out && \
    cd out && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j$(nproc) && \
    make install


# build vs-plugin: waifu2x-xc
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Waifu2x-w2xc && \
    cd VapourSynth-Waifu2x-w2xc && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# # build vs-plugin: vmaf
# RUN cd /opt/vs && \
#     git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-VMAF && \
#     cd VapourSynth-VMAF && \
#     meson build --prefix=/usr/local && \
#     cd build && \
#     ninja && \
#     ninja install


# build vs-plugin: bwdif
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bwdif  && \    
    cd VapourSynth-Bwdif && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: lghost
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-LGhost   && \ 
    cd VapourSynth-LGhost && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: curve
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Curve && \    
    cd VapourSynth-Curve && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: yadifmod
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Yadifmod  && \
    cd VapourSynth-Yadifmod && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# ImageMagick
RUN cd /opt/vs && \
    git clone https://github.com/ImageMagick/ImageMagick.git && \
    cd ImageMagick && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# build vs-plugin: imwwri
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/vapoursynth/vs-imwri && \
    cd vs-imwri && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: brestaudiosource
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/vapoursynth/bestaudiosource && \
    cd bestaudiosource && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: vs-miscfilters-obsolete
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/vapoursynth/vs-miscfilters-obsolete && \
    cd vs-miscfilters-obsolete && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: vs-removegrain
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/vapoursynth/vs-removegrain   && \
    cd vs-removegrain && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build vs-plugin: descale
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/Irrational-Encoding-Wizardry/descale && \
    cd descale && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install

# build avs-plugin: addGrainC
RUN cd /opt/avs && \
    git clone --depth 1 https://github.com/pinterf/AddGrainC && \
    cd AddGrainC && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j$(nproc) && \
    make install

# bulid avs-plugin: l-smash-works
RUN cd /opt/avs && \
    git clone --depth 1 https://github.com/HomeOfAviSynthPlusEvolution/L-SMASH-Works && \
    cd L-SMASH-Works/AviSynth && \
    meson build --prefix=/usr/local && \
    cd build && \
    ninja && \
    ninja install



# # Plugins  
# RUN cd /opt/vs && \
#     git clone https://github.com/darealshinji/vapoursynth-plugins.git && \
#     cd vapoursynth-plugins && \
#     ./autogen.sh && bash -c ./configure && \
#     make -j$(nproc) && make install && \
#     cd .. && rm -rf vapoursynth-plugins

RUN vspipe -v

# install vapoursynth-scripts
RUN pip install vsutil
RUN mkdir -p /usr/local/share/vsscripts
ADD https://raw.githubusercontent.com/dubhater/vapoursynth-adjust/master/adjust.py /usr/local/share/vsscripts/adjust.py
ADD https://raw.githubusercontent.com/HomeOfVapourSynthEvolution/havsfunc/master/havsfunc.py /usr/local/share/vsscripts/havsfunc.py
ADD https://raw.githubusercontent.com/HomeOfVapourSynthEvolution/mvsfunc/master/mvsfunc.py /usr/local/share/vsscripts/mvsfunc.py
ADD https://raw.githubusercontent.com/HomeOfVapourSynthEvolution/nnedi3_resample/master/nnedi3_resample.py /usr/local/share/vsscripts/nnedi3_resample.py
ADD https://raw.githubusercontent.com/HomeOfVapourSynthEvolution/vsTAAmbk/master/vsTAAmbk.py /usr/local/share/vsscripts/vsTAAmbk.py
ADD https://raw.githubusercontent.com/Irrational-Encoding-Wizardry/kagefunc/master/kagefunc.py /usr/local/share/vsscripts/kagefunc.py
ADD https://raw.githubusercontent.com/Irrational-Encoding-Wizardry/fvsfunc/master/fvsfunc.py /usr/local/share/vsscripts/fvsfunc.py
ADD https://raw.githubusercontent.com/xyx98/my-vapoursynth-script/master/xvs.py /usr/local/share/vsscripts/xvs.py

FROM golang as bin
COPY . . 
# compile 
RUN go build -o /tmp/ci-server -ldflags "-s -w" .

FROM env
COPY --from=bin /tmp/ci-server /usr/local/bin/ci-server
COPY templates.yaml /opt/templates.yaml
COPY example /opt/example
ENV template_file /opt/templates.yaml
ENV db_file /opt/main.db

ENTRYPOINT ["/usr/local/bin/ci-server"]
