#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# software
funpack = "/usr/bin/funpack"
gzip = "/bin/gzip"

# definitions
xcen = 370
ycen = 2650
xdim = 535
ydim = 535
simzipped = paste0("../../../sims/simdat/v5/calexp-HSC-R-8283-38.simulated-n4-a.fits.fz")
defmapzipped = paste0("../../sex_default/map/denlo4a.map.fits.gz")
maskzipped = paste0("../mask/denlo4a.mask.fits.gz")
dilmapzipped = paste0("../../sex_dilated/map/denlo4a.map.fits.gz")

# extract
simfile = "simfile.fits"
defmaptemp = strsplit(defmapzipped, ".gz")[[1]]
defmapfile = "defmapfile.fits"
masktemp = strsplit(maskzipped, ".gz")[[1]]
maskfile = "maskfile.fits"
dilmaptemp = strsplit(dilmapzipped, ".gz")[[1]]
dilmapfile = "dilmapfile.fits"
system(paste(funpack, "-O", simfile, simzipped))
system(paste0(gzip, " -d -k ", defmapzipped))
system(paste("mv", defmaptemp, defmapfile))
system(paste0(gzip, " -d -k ", maskzipped))
system(paste("mv", masktemp, maskfile))
system(paste0(gzip, " -d -k ", dilmapzipped))
system(paste("mv", dilmaptemp, dilmapfile))

# data
xlo = round(xcen - ((xdim+1)/2))
xhi = round(xcen + ((xdim+1)/2))
ylo = round(ycen - ((ydim+1)/2))
yhi = round(ycen + ((ydim+1)/2))
simdat = read.fitsim(simfile, hdu=1)[xlo:xhi,ylo:yhi]
magdat = read.fitsim(defmapfile, hdu=2)[xlo:xhi,ylo:yhi]
dildat = read.fitsim(maskfile, hdu=1)[xlo:xhi,ylo:yhi]
skyold = read.fitsim(defmapfile, hdu=3)[xlo:xhi,ylo:yhi]
skynew = read.fitsim(dilmapfile, hdu=3)[xlo:xhi,ylo:yhi]

# png
png(file="maskstamps.png", width=8, height=5.25, units="in", res=250)
par("mar"=c(0.5,0.5,1.5,0.5))
par("oma"=c(0,5,0.5,0))

# par
layout(rbind(c(1,3,5),c(2,4,6)))
line = 0.15

# plot
aimage(simdat, col.map="sls", scale.type="log", axes=FALSE, scale.lo=-0.025, scale.hi=5, xlab="", ylab="", smooth.fwhm=3)
mtext(side=3, line=line, text="original image")

aimage(magdat, col.map="sls", scale.type="lin", axes=FALSE, scale.lo=30, scale.hi=15, xlab="", ylab="", smooth.fwhm=0)
rect(xl=1, xr=537, yb=1, yt=537, border="black")
mtext(side=3, line=line, text="magnitude map")
col.bar("left", n=4, col.map="sls", scale.lo=30, scale.hi=15, scale.type="lin", flip=TRUE, inset=-3, seg.num=499, seg.gap=0.25)
mtext(side=2, line=3.75, text=bquote(paste(m[r])), las=1)

aimage(simdat, col.map="sls", scale.type="log", axes=FALSE, scale.lo=-0.025, scale.hi=5, xlab="", ylab="", smooth.fwhm=3)
image(1:537, 1:537, magdat, zlim=c(0.5,100), col="red", add=TRUE)
mtext(side=3, line=line, text="original segmentation map")

aimage(simdat, col.map="sls", scale.type="log", axes=FALSE, scale.lo=-0.025, scale.hi=5, xlab="", ylab="", smooth.fwhm=3)
image(1:537, 1:537, dildat, zlim=c(0.5,100), col="red", add=TRUE)
mtext(side=3, line=line, text="dilated mask")

aimage(skyold, col.map="sls", scale.type="log", axes=FALSE, scale.lo=-0.025, scale.hi=5, xlab="", ylab="", smooth.fwhm=0)
mtext(side=3, line=line, text="original background sky")

aimage(skynew, col.map="sls", scale.type="log", axes=FALSE, scale.lo=-0.025, scale.hi=5, xlab="", ylab="", smooth.fwhm=0)
mtext(side=3, line=line, text="dilated mask background sky")

# finish up
unlink(c(simfile, defmapfile, maskfile, dilmapfile))
graphics.off()
