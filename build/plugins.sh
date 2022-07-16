#!/bin/bash
set -xe

# build vs-plugin: l-smash
cd /opt/vs
git clone --depth 1 https://github.com/l-smash/l-smash.git
cd l-smash
./configure --prefix=/usr/local 
make 
make install 
ldconfig

# bulid vs-plugin: l-smash-works
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfAviSynthPlusEvolution/L-SMASH-Works
cd L-SMASH-Works/VapourSynth
meson build --prefix=/usr/local
cd build
ninja
ninja install
cd L-SMASH-Works/AviSynth
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: addgrain
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-AddGrain
cd VapourSynth-AddGrain
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: subtext
cd /opt/vs
git clone --depth 1 https://github.com/vapoursynth/subtext
cd subtext
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin awarpsharp2
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-awarpsharp2
cd vapoursynth-awarpsharp2
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: bifrost
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-bifrost
cd vapoursynth-bifrost
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install 

# build vs-plugin: builateral
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bilateral
cd VapourSynth-Bilateral
./configure --cache-file=/tmp/configure.cache --install=/usr/local/lib/vapoursynth
make -j$(nproc)
make install

# build vs-plugin: convo2d
# cd /opt/vs
# git clone --depth 1 https://github.com/chikuzen/convo2d
# cd convo2d
# ./configure --cache-file=/tmp/configure.cache
# make -j$(nproc)
# make install

# build vs-plugin: cnr2
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-cnr2
cd vapoursynth-cnr2
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install 

# build vs-plugin: combmask
cd /opt/vs
git clone --depth 1 https://github.com/chikuzen/CombMask
cd CombMask/vapoursynth/src
chmod +x configure
./configure --cache-file=/tmp/configure.cache --install=/usr/local/lib/vapoursynth
make -j$(nproc)
make install

# build vs-plugins: d2vsource
cd /opt/vs
git clone --depth 1 https://github.com/dwbuiten/d2vsource
cd d2vsource
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build fftw3f - with float support
cd /opt/vs
wget http://www.fftw.org/fftw-3.3.10.tar.gz
tar -xzf fftw-3.3.10.tar.gz
cd fftw-3.3.10
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local --enable-float --enable-threads --enable-shared
make -j$(nproc)
make install


# build vs-plugin: damb
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-damb
cd vapoursynth-damb
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: dctfilter
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DCTFilter
cd VapourSynth-DCTFilter
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: deblock
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Deblock 
cd VapourSynth-Deblock
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: deblockpp7
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DeblockPP7
cd VapourSynth-DeblockPP7
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: degrain-med
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-degrainmedian
cd vapoursynth-degrainmedian
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: delogo
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DeLogo
cd VapourSynth-DeLogo
./configure --cache-file=/tmp/configure.cache --install=/usr/local/lib/vapoursynth
make -j$(nproc)
make install

# build vs-plugin: bm3d
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-BM3D
cd VapourSynth-BM3D
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: cas
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-CAS
cd VapourSynth-CAS
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: ctmf
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-CTMF
cd VapourSynth-CTMF
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: dfttest
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DFTTest
cd VapourSynth-DFTTest
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: eedi2
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-EEDI2
cd VapourSynth-EEDI2
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: eedi3
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-EEDI3
cd VapourSynth-EEDI3
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: ffms2
cd /opt/vs
git clone --depth 1 https://github.com/FFMS/ffms2
cd ffms2
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: fft3dfilter
cd /opt/vs
git clone --depth 1 https://github.com/myrsloik/VapourSynth-FFT3DFilter
cd VapourSynth-FFT3DFilter
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: fieldhint
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-fieldhint
cd vapoursynth-fieldhint
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# builds vs-plugin: fillborders
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-fillborders
cd vapoursynth-fillborders
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: f3kdb
cd /opt/vs
git clone --depth 1 https://github.com/SAPikachu/flash3kyuu_deband
cd flash3kyuu_deband
./waf configure --prefix=/usr/local
./waf build
./waf install

# build vs-plugin: fluxsmmoth
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-fluxsmooth
cd vapoursynth-fluxsmooth
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: fmtconv
cd /opt/vs
git clone --depth 1 https://github.com/EleonoreMizo/fmtconv
cd fmtconv
cd ./build/unix
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install


# build vs-plugin: GenericFilters
cd /opt/vs
git clone --depth 1 https://github.com/myrsloik/GenericFilters
cd GenericFilters
cd src
./configure --cache-file=/tmp/configure.cache --install=/usr/local/lib/vapoursynth
make -j$(nproc)
make install

# build vs-plugin: histogram
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-histogram
cd vapoursynth-histogram
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: hqdn3d
cd /opt/vs
git clone --depth 1 https://github.com/Hinterwaeldlers/vapoursynth-hqdn3d
cd vapoursynth-hqdn3d
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# # build vs-plugin: image_reader
# cd /opt/vs
# git clone --depth 1 https://github.com/chikuzen/vsimagereader
# cd vsimagereader/src
# ./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
# make -j$(nproc)
# make install

# build vs-plugin: it
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-IT
cd VapourSynth-IT
./configure --cache-file=/tmp/configure.cache --install=/usr/local/lib/vapoursynth
make -j$(nproc)
make install


# build vs-plugin: knlMeansCL
cd /opt/vs
git clone --depth 1 https://github.com/Khanattila/KNLMeansCL
cd KNLMeansCL
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: msmoosh
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-msmoosh
cd vapoursynth-msmoosh
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: mvtools
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-mvtools
cd vapoursynth-mvtools
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: nnedi3
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-nnedi3
cd vapoursynth-nnedi3
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: nnedi3_cl
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-NNEDI3CL
cd VapourSynth-NNEDI3CL
meson build --prefix=/usr/local
cd build
ninja
ninja install

# # build vs-plugin: vsrawsource
# cd /opt/vs
# git clone --depth 1 https://github.com/chikuzen/vsrawsource
# cd vsrawsource
# ./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
# make -j$(nproc)
# make install

# build vs-plugin: read_mpls
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-ReadMpls
cd VapourSynth-ReadMpls
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: reduce_flicker
cd /opt/vs
git clone --depth 1 https://github.com/VFR-maniac/VapourSynth-ReduceFlicker
cd VapourSynth-ReduceFlicker
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: retinex
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Retinex
cd VapourSynth-Retinex
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: snm
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-SangNomMod
cd VapourSynth-SangNomMod
./configure --cache-file=/tmp/configure.cache --install=/usr/local/lib/vapoursynth
make -j$(nproc)
make install


# # build vs-plugin: screenchange
# COPY extras/screenchange-0.2.0-2 /usr/local/lib/vapoursynth

# build vs-plugin: scrawl
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-scrawl
cd vapoursynth-scrawl
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: scxvid
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-scxvid
cd vapoursynth-scxvid
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: ssiq
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-ssiq
cd vapoursynth-ssiq
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# # build vs-plugin: tc2cfr
# cd /opt/vs
# git clone --depth 1 https://github.com/gnaggnoyil/tc2cfr
# cd tc2cfr

# build vs-plugin: tcomb
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-tcomb
cd vapoursynth-tcomb
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: tdm
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TDeintMod
cd VapourSynth-TDeintMod
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: temporalsoften
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-temporalsoften
cd vapoursynth-temporalsoften
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: TNLMeans
cd /opt/vs
git clone --depth 1 https://github.com/VFR-maniac/VapourSynth-TNLMeans
cd VapourSynth-TNLMeans
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: ttempsmooth
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TTempSmooth
cd VapourSynth-TTempSmooth
meson build --prefix=/usr/local
cd build
ninja
ninja install


# build vs-plugin: vaguedenoiser
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-VagueDenoiser
cd VapourSynth-VagueDenoiser
./configure --cache-file=/tmp/configure.cache --install=/usr/local/lib/vapoursynth
make -j$(nproc)
make install

# build vs-plugin: videoscope
cd /opt/vs
git clone --depth 1 https://github.com/dubhater/vapoursynth-videoscope
cd vapoursynth-videoscope
./autogen.sh
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: w3fdif
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-W3FDIF
cd VapourSynth-W3FDIF
./configure --cache-file=/tmp/configure.cache --install=/usr/local/lib/vapoursynth
make -j$(nproc)
make install

# install waifu2x-ncnn-vulkan
# cd /opt/vs
# apt-get install libvulkan-dev
# git clone --depth 1 https://github.com/nihui/waifu2x-ncnn-vulkan
# cd waifu2x-ncnn-vulkan
# git submodule update --init --recursive
# mkdir build
# cd build
# cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local ../src
# cmake --build -j$(nproc) 

# build vs-plugin: waifu2x-cc
cd /opt/vs
git clone --depth 1 https://github.com/DeadSix27/waifu2x-converter-cpp
cd waifu2x-converter-cpp
mkdir out
cd out
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local ..
make -j$(nproc)
make install


# build vs-plugin: waifu2x-xc
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Waifu2x-w2xc
cd VapourSynth-Waifu2x-w2xc
meson build --prefix=/usr/local
cd build
ninja
ninja install

# # build vs-plugin: vmaf
# cd /opt/vs
# git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-VMAF
# cd VapourSynth-VMAF
# meson build --prefix=/usr/local
# cd build
# ninja
# ninja install


# build vs-plugin: bwdif
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bwdif 
cd VapourSynth-Bwdif
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: lghost
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-LGhost   
cd VapourSynth-LGhost
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: curve
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Curve
cd VapourSynth-Curve
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: yadifmod
cd /opt/vs
git clone --depth 1 https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Yadifmod 
cd VapourSynth-Yadifmod
meson build --prefix=/usr/local
cd build
ninja
ninja install

# ImageMagick
cd /opt/vs
git clone https://github.com/ImageMagick/ImageMagick.git
cd ImageMagick
./configure --cache-file=/tmp/configure.cache --prefix=/usr/local
make -j$(nproc)
make install

# build vs-plugin: imwwri
cd /opt/vs
git clone --depth 1 https://github.com/vapoursynth/vs-imwri
cd vs-imwri
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: brestaudiosource
cd /opt/vs
git clone --depth 1 https://github.com/vapoursynth/bestaudiosource
cd bestaudiosource
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: vs-miscfilters-obsolete
cd /opt/vs
git clone --depth 1 https://github.com/vapoursynth/vs-miscfilters-obsolete
cd vs-miscfilters-obsolete
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: vs-removegrain
cd /opt/vs
git clone --depth 1 https://github.com/vapoursynth/vs-removegrain  
cd vs-removegrain
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build vs-plugin: descale
cd /opt/vs
git clone --depth 1 https://github.com/Irrational-Encoding-Wizardry/descale
cd descale
meson build --prefix=/usr/local
cd build
ninja
ninja install

# build avs-plugin: addGrainC
cd /opt/avs
git clone --depth 1 https://github.com/pinterf/AddGrainC
cd AddGrainC
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local ..
make -j$(nproc)
make install

# # Plugins  
# RUN cd /opt/vs && \
#     git clone https://github.com/darealshinji/vapoursynth-plugins.git && \
#     cd vapoursynth-plugins && \
#     ./autogen.sh && bash -c ./configure --cache-file=/tmp/configure.cache && \
#     make -j$(nproc) && make install && \
#     cd .. && rm -rf vapoursynth-plugins