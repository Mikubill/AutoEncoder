FROM python:bullseye as env

ENV WORKDIR='/opt'
ENV LD_LIBRARY_PATH='/usr/local/lib:/usr/lib'
ENV LIBRARY_PATH='/usr/local/lib:/usr/lib'
ENV PKG_CONFIG_PATH='/usr/local/lib/pkgconfig:/usr/lib/pkgconfig'
ENV PYTHONPATH='/usr/local/lib/python3.10/site-packages'
ENV CXXFLAGS="$CXXFLAGS -fPIC"
ENV CFLAGS="$CFLAGS -fPIC"

WORKDIR ${WORKDIR}

# Development dependencies
RUN apt update && \
    apt -y upgrade && \
    apt -y install\
        dpkg apt-utils unzip tar p7zip \
        # Development dependencies
        build-essential autoconf autogen automake autotools-dev curl gperf clang \
        yasm nasm cmake xxd libtool pkg-config git xz-utils wget gettext autopoint \
        # ffmpeg dependencies
        libgnutls28-dev libva-dev libunistring-dev libnuma-dev libdav1d-dev \
        libxcb-shm0-dev libxcb-xfixes0-dev libvdpau-dev libxcb1-dev libxext-dev \
        # eedi2&eedi3 depend on opencl and boost
        ocl-icd-opencl-dev opencl-c-headers opencl-clhpp-headers \
        libboost-filesystem-dev libboost-system-dev libboost-thread-dev && \
    apt clean && \
    # python build tools
    pip install --upgrade wheel meson cpython cython pip ninja && \
    mkdir -p /opt/dep /opt/vs /opt/avs 

# install deps
COPY build /opt/build
RUN bash /opt/build/deps.sh

# install vapoursynth and avisynth
RUN cd /opt/vs && \
    git clone --depth 1 https://github.com/vapoursynth/vapoursynth.git  && \
    cd vapoursynth && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local --disable-shared && \
    make -j1 V=1 && \
    make install && \

    # expr: avisynth
    cd /opt/avs && \
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


# install vs plugins 
RUN bash /opt/build/plugins.sh

# install vapoursynth-scripts\
RUN bash /opt/build/scripts.sh

FROM golang as bin
WORKDIR /app
COPY go.mod ./
COPY go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -v -o /tmp/ci-server -ldflags "-w -s -X main.GitCommit="$(git rev-parse HEAD)

FROM env
COPY --from=bin /tmp/ci-server /usr/local/bin/ci-server
COPY templates.yaml /opt/templates.yaml
COPY example /opt/example
ENV template_file /opt/templates.yaml
ENV db_file /opt/main.db
ENV addr :8080
RUN rm -rf /opt/build && \
    vspipe -v && ci-server -v

ENTRYPOINT ["ci-server"]
