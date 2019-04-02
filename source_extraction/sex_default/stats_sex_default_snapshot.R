#!/usr/bin/Rscript --no-init-file

# setup
#require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
dat = read.csv("stats_sex_default.csv")

id = dat[,"ID"]
back = dat[,"BACK"]
rms = dat[,"RMS"]
pixelsize = 0.168

backmag = -2.5*log10(back/(pixelsize^2)) + 27

png(file="stats_sex_default_snapshot.png", width=5, height=5, units="in", res=300)
par("mar"=c(4,4,1,1))

aplot(rms, backmag, type="n", las=1, xlab="Pixel-to-Pixel Sky RMS", ylab="Detected background level / mag", xlim=c(0.05,0.0555), ylim=c(30.5,27.5))
text(x=rms, y=backmag, lab=id)

graphics.off()

