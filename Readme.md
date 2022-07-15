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

<sub<l-smash/l-smash</sub>

<sub<HomeOfAviSynthPlusEvolution/L-SMASH-Works</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-AddGrain</sub>

<sub<vapoursynth/subtext</sub>

<sub<dubhater/vapoursynth-awarpsharp2</sub>

<sub<dubhater/vapoursynth-bifrost</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-Bilateral</sub>

<sub<chikuzen/convo2d</sub>

<sub<dubhater/vapoursynth-cnr2</sub>

<sub<chikuzen/CombMask</sub>

<sub<dwbuiten/d2vsource</sub>

<sub<dubhater/vapoursynth-damb</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-DCTFilter</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-Deblock 

<sub<HomeOfVapourSynthEvolution/VapourSynth-DeblockPP7</sub>

<sub<dubhater/vapoursynth-degrainmedian</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-DeLogo</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-BM3D</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-CAS</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-CTMF</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-DFTTest</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-EEDI2</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-EEDI3</sub>

<sub<FFMS/ffms2</sub>

<sub<myrsloik/VapourSynth-FFT3DFilter</sub>

<sub<dubhater/vapoursynth-fieldhint</sub>

<sub<dubhater/vapoursynth-fillborders</sub>

<sub<SAPikachu/flash3kyuu_deband</sub>

<sub<dubhater/vapoursynth-fluxsmooth</sub>

<sub<EleonoreMizo/fmtconv</sub>

<sub<myrsloik/GenericFilters</sub>

<sub<dubhater/vapoursynth-histogram</sub>

<sub<Hinterwaeldlers/vapoursynth-hqdn3d</sub>

<sub<chikuzen/vsimagereader</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-IT</sub>

<sub<Khanattila/KNLMeansCL</sub>

<sub<dubhater/vapoursynth-msmoosh</sub>

<sub<dubhater/vapoursynth-mvtools</sub>

<sub<dubhater/vapoursynth-nnedi3</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-NNEDI3CL</sub>

<sub<chikuzen/vsrawsource</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-ReadMpls</sub>

<sub<VFR-maniac/VapourSynth-ReduceFlicker</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-Retinex</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-SangNomMod</sub>

<sub<dubhater/vapoursynth-scrawl</sub>

<sub<dubhater/vapoursynth-scxvid</sub>

<sub<dubhater/vapoursynth-ssiq</sub>

<sub<gnaggnoyil/tc2cfr</sub>

<sub<dubhater/vapoursynth-tcomb</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-TDeintMod</sub>

<sub<dubhater/vapoursynth-temporalsoften</sub>

<sub<VFR-maniac/VapourSynth-TNLMeans</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-TTempSmooth</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-VagueDenoiser</sub>

<sub<dubhater/vapoursynth-videoscope</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-W3FDIF</sub>

<sub<nihui/waifu2x-ncnn-vulkan</sub>

<sub<DeadSix27/waifu2x-converter-cpp</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-Waifu2x-w2xc</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-VMAF</sub>

<sub<HomeOfVapourSynthEvolution/VapourSynth-Bwdif     

<sub<HomeOfVapourSynthEvolution/VapourSynth-LGhost   

<sub<HomeOfVapourSynthEvolution/VapourSynth-Curve    

<sub<HomeOfVapourSynthEvolution/VapourSynth-Yadifmod 

<sub<ImageMagick/ImageMagick</sub>

<sub<vapoursynth/vs-imwri</sub>

<sub<vapoursynth/bestaudiosource</sub>

<sub<vapoursynth/vs-miscfilters-obsolete</sub>

<sub<vapoursynth/vs-removegrain</sub>

<sub<Irrational-Encoding-Wizardry/descale</sub>

<sub<pinterf/AddGrainC</sub>