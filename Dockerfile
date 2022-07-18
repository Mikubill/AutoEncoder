FROM python:bullseye as env

ENV WORKDIR='/opt'
ENV LD_LIBRARY_PATH='/usr/local/lib'
ENV LIBRARY_PATH='/usr/local/lib'
ENV PKG_CONFIG_PATH='/usr/local/lib/pkgconfig'
ENV PYTHONPATH='/usr/local/lib/python3.10/site-packages'
ENV CXXFLAGS="$CXXFLAGS -fPIC"
ENV CFLAGS="$CFLAGS -fPIC"

WORKDIR ${WORKDIR}

# Development dependencies
RUN apt update && \
    apt -y upgrade && \
    apt -y install\
        dpkg apt-utils unzip tar p7zip unrar-free \
        # Development dependencies
        build-essential autoconf autogen automake autotools-dev curl gperf clang \
        yasm nasm cmake xxd libtool pkg-config git xz-utils wget gettext autopoint \
        # ffmpeg dependencies
        libgnutls28-dev libva-dev libunistring-dev libnuma-dev libdav1d-dev \
        libxcb-shm0-dev libxcb-xfixes0-dev libvdpau-dev libxcb1-dev libxext-dev \
        # eedi2&eedi3 depend on opencl and boost
        ocl-icd-opencl-dev opencl-c-headers opencl-clhpp-headers libc6-dev \
        libboost-filesystem-dev libboost-system-dev libboost-thread-dev && \
    apt clean && \
    # python build tools
    pip install --upgrade wheel meson cpython cython pip ninja && \
    mkdir -p /opt/dep /opt/vs /opt/avs 

# install deps
COPY build/deps.sh /opt/build/deps.sh
RUN bash /opt/build/deps.sh

# install vapoursynth and avisynth
COPY build/vscore.sh /opt/build/vscore.sh
RUN bash /opt/build/vscore.sh

# install ffmpeg
COPY build/ffcore.sh /opt/build/ffcore.sh
RUN bash /opt/build/ffcore.sh

# install OpenCV
# ENV OPENCV_VERSION=4.6.0
# COPY build/cvcore.sh /opt/build/cvcore.sh
# RUN bash /opt/build/cvcore.sh

# recompile some modules
COPY build/deps2.sh /opt/build/deps2.sh
RUN bash /opt/build/deps2.sh

# install vs plugins 
COPY build/plugins.sh /opt/build/plugins.sh
RUN bash /opt/build/plugins.sh

# install vapoursynth-scripts\
COPY build/scripts.sh /opt/build/scripts.sh
RUN bash /opt/build/scripts.sh

FROM golang as bin
WORKDIR /app
COPY go.mod ./
COPY go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -v -o /tmp/ci-server -ldflags "-w -s -X main.GitCommit="$(git rev-parse HEAD)

FROM env

# # install fonts
# RUN wget -O /tmp/fonts.rar https://github.com/Mikubill/AutoEncoder/releases/download/v0.1-assets/fonts.rar && \
#     mkdir /usr/share/fonts/vcb-fonts-silm && \
#     unrar x -y /tmp/fonts.rar /usr/share/fonts/vcb-fonts-silm && \
#     rm -rf /tmp/fonts.rar && \
#     fc-cache -fv

COPY --from=bin /tmp/ci-server /usr/local/bin/ci-server
COPY templates.yaml /opt/templates.yaml
COPY example /opt/example

ENV TPL_FILE /opt/templates.yaml
ENV DB_FILE /opt/main.db
ENV LISTEN_ADDR :8080
RUN rm -rf /opt/build && \
    mkdir /opt/workspace && \
    mkdir /opt/tmp && \
    python -m site && \
    vspipe -v && ci-server -v

ENTRYPOINT ["ci-server"]
