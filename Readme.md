# AutoEncoder

通用压制框架，附带一个简陋的任务系统和网页接口。

因为没有找到方便 Linux 安装的 filter 插件，所以暂时只支持不依赖 vsfm 的脚本。

## Templates

模版就是多个任务的组合，可以理解成简单的workflow。模版定义在`templates.yaml`，这个文件也位于镜像的`/opt/`中。

注意由于`scanner`的限制，部分带进度条的程序需要把进度条关掉才能正常运行。

## Plugins

vs和avs以及插件都安装在`/usr/local/{lib,share}/{vapoursynth,avisynth}`下，如有需要可以自行编译增删。

默认编译了一部分常见的vs插件，具体如下

## Credits

l-smash/l-smash

HomeOfAviSynthPlusEvolution/L-SMASH-Works

HomeOfVapourSynthEvolution/VapourSynth-AddGrain

vapoursynth/subtext

dubhater/vapoursynth-awarpsharp2

dubhater/vapoursynth-bifrost

HomeOfVapourSynthEvolution/VapourSynth-Bilateral

chikuzen/convo2d

dubhater/vapoursynth-cnr2

chikuzen/CombMask

dwbuiten/d2vsource

dubhater/vapoursynth-damb

HomeOfVapourSynthEvolution/VapourSynth-DCTFilter

HomeOfVapourSynthEvolution/VapourSynth-Deblock 

HomeOfVapourSynthEvolution/VapourSynth-DeblockPP7

dubhater/vapoursynth-degrainmedian

HomeOfVapourSynthEvolution/VapourSynth-DeLogo

HomeOfVapourSynthEvolution/VapourSynth-BM3D

HomeOfVapourSynthEvolution/VapourSynth-CAS

HomeOfVapourSynthEvolution/VapourSynth-CTMF

HomeOfVapourSynthEvolution/VapourSynth-DFTTest

HomeOfVapourSynthEvolution/VapourSynth-EEDI2

HomeOfVapourSynthEvolution/VapourSynth-EEDI3

FFMS/ffms2

myrsloik/VapourSynth-FFT3DFilter

dubhater/vapoursynth-fieldhint

dubhater/vapoursynth-fillborders

SAPikachu/flash3kyuu_deband

dubhater/vapoursynth-fluxsmooth

EleonoreMizo/fmtconv

myrsloik/GenericFilters

dubhater/vapoursynth-histogram

Hinterwaeldlers/vapoursynth-hqdn3d

chikuzen/vsimagereader

HomeOfVapourSynthEvolution/VapourSynth-IT

Khanattila/KNLMeansCL

dubhater/vapoursynth-msmoosh

dubhater/vapoursynth-mvtools

dubhater/vapoursynth-nnedi3

HomeOfVapourSynthEvolution/VapourSynth-NNEDI3CL

chikuzen/vsrawsource

HomeOfVapourSynthEvolution/VapourSynth-ReadMpls

VFR-maniac/VapourSynth-ReduceFlicker

HomeOfVapourSynthEvolution/VapourSynth-Retinex

HomeOfVapourSynthEvolution/VapourSynth-SangNomMod

dubhater/vapoursynth-scrawl

dubhater/vapoursynth-scxvid

dubhater/vapoursynth-ssiq

gnaggnoyil/tc2cfr

dubhater/vapoursynth-tcomb

HomeOfVapourSynthEvolution/VapourSynth-TDeintMod

dubhater/vapoursynth-temporalsoften

VFR-maniac/VapourSynth-TNLMeans

HomeOfVapourSynthEvolution/VapourSynth-TTempSmooth

HomeOfVapourSynthEvolution/VapourSynth-VagueDenoiser

dubhater/vapoursynth-videoscope

HomeOfVapourSynthEvolution/VapourSynth-W3FDIF

nihui/waifu2x-ncnn-vulkan

DeadSix27/waifu2x-converter-cpp

HomeOfVapourSynthEvolution/VapourSynth-Waifu2x-w2xc

HomeOfVapourSynthEvolution/VapourSynth-VMAF

HomeOfVapourSynthEvolution/VapourSynth-Bwdif     

HomeOfVapourSynthEvolution/VapourSynth-LGhost   

HomeOfVapourSynthEvolution/VapourSynth-Curve    

HomeOfVapourSynthEvolution/VapourSynth-Yadifmod 

ImageMagick/ImageMagick

vapoursynth/vs-imwri

vapoursynth/bestaudiosource

vapoursynth/vs-miscfilters-obsolete

vapoursynth/vs-removegrain

Irrational-Encoding-Wizardry/descale

pinterf/AddGrainC