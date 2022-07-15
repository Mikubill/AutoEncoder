# AutoEncoder

通用压制框架，附带一个简陋的任务系统和网页接口。

因为没有找到方便 Linux 安装的 filter 插件，所以暂时只支持不依赖 vsfm 的脚本。

# Templates

模版就是多个任务的组合，可以理解成简单的workflow。模版定义在`templates.yaml`，这个文件也位于镜像的`/opt/`中。

注意由于`scanner`的限制，部分带进度条的程序需要把进度条关掉才能正常运行。

# Plugins

vs和avs以及插件都安装在`/usr/local/{lib,share}/{vapoursynth,avisynth}`下，如有需要可以自行编译增删。

默认编译了一部分常见的vs插件，具体如下

```
https://github.com/l-smash/l-smash.git
https://github.com/HomeOfAviSynthPlusEvolution/L-SMASH-Works
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-AddGrain
https://github.com/vapoursynth/subtext
https://github.com/dubhater/vapoursynth-awarpsharp2
https://github.com/dubhater/vapoursynth-bifrost
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bilateral
https://github.com/chikuzen/convo2d
https://github.com/dubhater/vapoursynth-cnr2
https://github.com/chikuzen/CombMask
https://github.com/dwbuiten/d2vsource
https://github.com/dubhater/vapoursynth-damb
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DCTFilter
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Deblock 
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DeblockPP7
https://github.com/dubhater/vapoursynth-degrainmedian
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DeLogo
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-BM3D
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-CAS
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-CTMF
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DFTTest
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-EEDI2
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-EEDI3
https://github.com/FFMS/ffms2
https://github.com/myrsloik/VapourSynth-FFT3DFilter
https://github.com/dubhater/vapoursynth-fieldhint
https://github.com/dubhater/vapoursynth-fillborders
https://github.com/SAPikachu/flash3kyuu_deband
https://github.com/dubhater/vapoursynth-fluxsmooth
https://github.com/EleonoreMizo/fmtconv
https://github.com/myrsloik/GenericFilters
https://github.com/dubhater/vapoursynth-histogram
https://github.com/Hinterwaeldlers/vapoursynth-hqdn3d
https://github.com/chikuzen/vsimagereader
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-IT
https://github.com/Khanattila/KNLMeansCL
https://github.com/dubhater/vapoursynth-msmoosh
https://github.com/dubhater/vapoursynth-mvtools
https://github.com/dubhater/vapoursynth-nnedi3
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-NNEDI3CL
https://github.com/chikuzen/vsrawsource
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-ReadMpls
https://github.com/VFR-maniac/VapourSynth-ReduceFlicker
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Retinex
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-SangNomMod
https://github.com/dubhater/vapoursynth-scrawl
https://github.com/dubhater/vapoursynth-scxvid
https://github.com/dubhater/vapoursynth-ssiq
https://github.com/gnaggnoyil/tc2cfr
https://github.com/dubhater/vapoursynth-tcomb
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TDeintMod
https://github.com/dubhater/vapoursynth-temporalsoften
https://github.com/VFR-maniac/VapourSynth-TNLMeans
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TTempSmooth
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-VagueDenoiser
https://github.com/dubhater/vapoursynth-videoscope
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-W3FDIF
https://github.com/nihui/waifu2x-ncnn-vulkan
https://github.com/DeadSix27/waifu2x-converter-cpp
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Waifu2x-w2xc
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-VMAF
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bwdif     
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-LGhost   
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Curve    
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Yadifmod 
https://github.com/ImageMagick/ImageMagick.git
https://github.com/vapoursynth/vs-imwri
https://github.com/vapoursynth/bestaudiosource
https://github.com/vapoursynth/vs-miscfilters-obsolete
https://github.com/vapoursynth/vs-removegrain  
https://github.com/Irrational-Encoding-Wizardry/descale
https://github.com/pinterf/AddGrainC
```


