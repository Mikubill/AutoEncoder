import vapoursynth as vs
import mvsfunc as mvf

core = vs.core
core.num_threads = 12
core.max_cache_size = 1000

src = core.lsmas.LWLibavSource("input.mkv")
res = core.rgvs.RemoveGrain(src, 1)
res = core.sub.TextFile(src, "subtitle.ass")
res = mvf.Depth(res)
res.set_output()
