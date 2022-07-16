#!/bin/bash
set -xe

pip install vsutil
mkdir -p /usr/local/share/vsscripts
curl -fsSL https://raw.githubusercontent.com/dubhater/vapoursynth-adjust/master/adjust.py -o /usr/local/share/vsscripts/adjust.py
curl -fsSL https://raw.githubusercontent.com/HomeOfVapourSynthEvolution/havsfunc/master/havsfunc.py -o /usr/local/share/vsscripts/havsfunc.py
curl -fsSL https://raw.githubusercontent.com/HomeOfVapourSynthEvolution/mvsfunc/master/mvsfunc.py -o /usr/local/share/vsscripts/mvsfunc.py
curl -fsSL https://raw.githubusercontent.com/HomeOfVapourSynthEvolution/nnedi3_resample/master/nnedi3_resample.py -o /usr/local/share/vsscripts/nnedi3_resample.py
curl -fsSL https://raw.githubusercontent.com/HomeOfVapourSynthEvolution/vsTAAmbk/master/vsTAAmbk.py -o /usr/local/share/vsscripts/vsTAAmbk.py
curl -fsSL https://raw.githubusercontent.com/Irrational-Encoding-Wizardry/kagefunc/master/kagefunc.py -o /usr/local/share/vsscripts/kagefunc.py
curl -fsSL https://raw.githubusercontent.com/Irrational-Encoding-Wizardry/fvsfunc/master/fvsfunc.py -o /usr/local/share/vsscripts/fvsfunc.py
curl -fsSL https://raw.githubusercontent.com/xyx98/my-vapoursynth-script/master/xvs.py -o /usr/local/share/vsscripts/xvs.py