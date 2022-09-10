#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# software
funpack = "/usr/bin/funpack"
gzip = "/bin/gzip"

# definitions
zlo = -0.04
zhi = 0.2
ztype = 'atan'
xcen = 370
ycen = 2650
xdim = 535
ydim = 535
simzipped = paste0("../../sims/simdat/v5/calexp-HSC-R-8283-38.simulated-n4-a.fits.fz")
defmapzipped = paste0("../../source_extraction/dmstack_default/map/denlo4a.map.fits.gz")
optmapzipped = paste0("../../source_extraction/dmstack_optimised/map/denlo4a.map.fits.gz")
fn = function(flux){-2.5*log10(flux/(0.168^2))+27}
ifn = function(mag){(10^(-0.4*(mag-27)))*(0.168^2)}
magvals = seq(31,27,by=-0.1)
magcols = grey(seq(0.9, 0, length=length(magvals)))
magltys = c()
for (i in 1:length(magvals)){
    if(abs(round(magvals[i])-magvals[i]) < 0.001){
        magltys = c(magltys, 1)
    }else{
        magltys = c(magltys, 3)
    }
}
maglwd = 3
maglend = "round"

# extract
simfile = "simfile.fits"
defmaptemp = strsplit(defmapzipped, ".gz")[[1]]
defmapfile = "defmapfile.fits"
optmaptemp = strsplit(optmapzipped, ".gz")[[1]]
optmapfile = "optmapfile.fits"
system(paste(funpack, "-O", simfile, simzipped))
system(paste0(gzip, " -d -k ", defmapzipped))
system(paste("mv", defmaptemp, defmapfile))
system(paste0(gzip, " -d -k ", optmapzipped))
system(paste("mv", optmaptemp, optmapfile))

# data
xlo = round(xcen - ((xdim+1)/2))
xhi = round(xcen + ((xdim+1)/2))
ylo = round(ycen - ((ydim+1)/2))
yhi = round(ycen + ((ydim+1)/2))
simdat = read.fitsim(simfile, hdu=1)[xlo:xhi,ylo:yhi]
defdat = read.fitsim(defmapfile, hdu=1)[xlo:xhi,ylo:yhi]
optdat = read.fitsim(optmapfile, hdu=1)[xlo:xhi,ylo:yhi]
defsky = read.fitsim(defmapfile, hdu=3)[xlo:xhi,ylo:yhi]
optsky = read.fitsim(optmapfile, hdu=3)[xlo:xhi,ylo:yhi]

# png
png(file=paste0("mask_dmstack.png"), width=8, height=4.97, units="in", res=255)
par("mar"=c(0.5,0.5,1.5,0.5))
par("oma"=c(0,0,0.5,0))

# par
layout(rbind(c(1,2,3,6),c(0,4,5,6)), widths=c(3,3,3,1))
line = 0.25
colmap = "grey"
skycolmap = "terrain"
colinvert = FALSE
skycolinvert = TRUE
colmask = "hotpink"
maskalpha = 1

# plot
aimage(simdat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=3, col.invert=colinvert)
mtext(side=3, line=line, text="original image")

aimage(simdat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=3, col.invert=colinvert)
image(1:537, 1:537, defdat, zlim=c(0.5,100), col=colmask, add=TRUE)
mtext(side=3, line=line, text="orig. image & P6 seg. map")

aimage(fn(defsky), col.map=skycolmap, scale.type="lin", axes=FALSE, scale.lo=27, scale.hi=30, xlab="", ylab="", smooth.fwhm=0, col.invert=skycolinvert)
mtext(side=3, line=line, text="P6 background")

aimage(simdat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=3, col.invert=colinvert)
image(1:537, 1:537, optdat, zlim=c(0.5,100), col=colmask, add=TRUE)
mtext(side=3, line=line, text="orig. image & S128 seg. map")

aimage(fn(optsky), col.map=skycolmap, scale.type="lin", axes=FALSE, scale.lo=27, scale.hi=30, xlab="", ylab="", smooth.fwhm=0, col.invert=skycolinvert)
mtext(side=3, line=line, text="S128 background")

# contour legend
plot(NA, xlim=c(0,1), ylim=c(0,1), axes=FALSE)
istep = 10
yoff = 0.01
linelen = 0.9
xpos = 0.45
count = 0
for(i in seq(max(magvals), min(magvals), len=9)){
    count = count + 1
    points(x=xpos, y=0+(count/istep)+yoff-0.045, pch=15, col=terrain.colors(9, rev=!skycolinvert)[count], cex=5)
    text(x=xpos, y=0+(count/istep)+yoff, lab=formatC(i, format='f', digits=1))
}
text(x=xpos, y=0+(count/istep)+yoff+0.075, lab=bquote(mu), cex=1.75)

# finish up
unlink(c(simfile, defmapfile, optmapfile))
graphics.off()
