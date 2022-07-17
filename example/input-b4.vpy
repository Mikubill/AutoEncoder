import sys
sys.path.append('/usr/local/share/vsscripts')

import vapoursynth as vs
import sys 
import mvsfunc as mvf
import havsfunc as haf
import nnedi3_resample as nnrs
from vapoursynth import core

core.std.LoadPlugin("/usr/local/lib/libf3kdb.so")
core.std.LoadPlugin("/usr/local/lib/x86_64-linux-gnu/libmvtools.so")
core.std.LoadPlugin("/usr/local/lib/libfmtconv.so")
# core.std.LoadPlugin("/usr/local/lib/x86_64-linux-gnu/vapoursynth/libknlmeanscl.so")

source = core.lsmas.LWLibavSource("input.mkv")
src8  = core.std.AssumeFPS(source, fpsnum=24000, fpsden=1001)
src16 = mvf.Depth(src8, depth=16)

src = core.bm3d.RGB2OPP(mvf.ToRGB(src16))
ref = haf.SMDegrain(src, 3, 200, RefineMotion=True, prefilter=3)
flt = core.bm3d.VFinal(src, ref, radius=1, matrix=100, sigma=2.0).bm3d.VAggregate(radius=1)
flt = mvf.ToYUV(core.bm3d.OPP2RGB(flt))

nr8    = mvf.Depth(flt, depth=8)
luma   = core.std.ShufflePlanes(nr8, 0, vs.YUV).resize.Bilinear(format=vs.YUV420P8)
nrmasks = core.tcanny.TCanny(nr8,sigma=0.8,op=2,mode=1,planes=[0,1,2]).std.Expr(["x 7 < 0 65535 ?",""],vs.YUV420P16)
nrmaskb = core.tcanny.TCanny(nr8,sigma=1.3,t_h=6.5,op=2,planes=0)
nrmaskg = core.tcanny.TCanny(nr8,sigma=1.1,t_h=5.0,op=2,planes=0)
nrmask  = core.std.Expr([nrmaskg,nrmaskb,nrmasks, nr8],["a 20 < 65535 a 48 < x 256 * a 96 < y 256 * z ? ? ?",""],vs.YUV420P16)
nrmask  = core.std.Maximum(nrmask,0).std.Maximum(0).std.Minimum(0)
nrmask  = core.rgvs.RemoveGrain(nrmask,[20,0])

debd  = core.f3kdb.Deband(flt,12,24,16,16,0,0,output_depth=16)
debd  = core.f3kdb.Deband(debd,20,56,32,32,0,0,output_depth=16)
debd  = mvf.LimitFilter(debd,flt,thr=0.6,thrc=0.5,elast=2.0)
debd  = core.std.MaskedMerge(debd,flt,nrmask,first_plane=True)

mvf.Depth(debd,10).set_output() 
