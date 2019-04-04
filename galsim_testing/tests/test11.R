/#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
#set.seed(3125)

# set sky level
sky_level_pixel = 25
feedme = readLines("test11.yaml")
skyline = grep("&sky_level_pixel", readLines("test11.yaml"))
feedme[skyline] = paste0("    - &sky_level_pixel ", sky_level_pixel, " # 1.6450475")
cat(feedme, file="test11.yaml", sep="\n")

# run GalSim
system("/usr/local/bin/galsim test11.yaml")

# data
#sky_level_pixel = as.numeric(strsplit(grep("&sky_level_pixel", readLines("test11.yaml"), v=T), " +")[[1]][4])
dat = read.fitsim("output/test11.fits")
breaks = -200:200 + 0.5
mids = breaks[-1] - 0.5
h = hist(dat, plot=FALSE, breaks=breaks)
bw = diff(h$breaks)[1]

#rp = rpois(n=length(dat), lambda=sky_level_pixel) - sky_level_pixel
#hrp = hist(rp, plot=FALSE, breaks=breaks)

yp = dpois(mids+sky_level_pixel, lambda=sky_level_pixel) * bw

# dev
pdf(file="output/test11.pdf", width=5, height=5)
par("mar"=c(2.5,3.5,1,1))

# plot
aplot(NA, xlim=qpois(c(0.001,0.999),sky_level_pixel)-sky_level_pixel+c(-5,5), ylim=c(1,max(h$counts)*2.5)/length(dat), axes=F, xlab="pixel value / counts", ylab="density\n", log="y", mgp=c(1.25,0.25,0))
bars(h$mids, h$counts/length(dat), width=bw*0.85)
#points(h$mids, h$counts, pch=16)
lines(mids, yp)
#points(hrp$mids, hrp$counts)
abline(v=0, lwd=2, lty=3, lend=1)
alegend("topright", legend=c("GalSim CCD noise", "Poisson deviate"), type=list(f=list(col="grey75",border=NA), l=list(col="black")))
label("topleft", lab=paste0("sky level = ", sky_level_pixel), col="black")
aaxes(las=1, xnmin=9, yformat="p")
abox()

# finish up
graphics.off()

