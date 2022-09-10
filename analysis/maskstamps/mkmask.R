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
codebase = commandArgs(TRUE)
if (length(codebase) == 0){
    codebase = "sex"
}
simzipped = paste0("../../sims/simdat/v5/calexp-HSC-R-8283-38.simulated-n4-a.fits.fz")
defmapzipped = paste0("../../source_extraction/",codebase,"_default/map/denlo4a.map.fits.gz")
dilmaskzipped = paste0("../../source_extraction/",codebase,"_dilated/mask/denlo4a.mask.fits.gz")
dilmapzipped = paste0("../../source_extraction/",codebase,"_dilated/map/denlo4a.map.fits.gz")
model0zipped = paste0("../../source_extraction/",codebase,"_modelled/model/denlo4a.model0.fits.fz")
model1zipped = paste0("../../source_extraction/",codebase,"_modelled/model/denlo4a.model1.fits.fz")
modelmapzipped = paste0("../../source_extraction/",codebase,"_modelled/map/denlo4a.map.fits.gz")
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
dilmasktemp = strsplit(dilmaskzipped, ".gz")[[1]]
dilmaskfile = "dilmaskfile.fits"
dilmaptemp = strsplit(dilmapzipped, ".gz")[[1]]
dilmapfile = "dilmapfile.fits"
system(paste(funpack, "-O", simfile, simzipped))
system(paste0(gzip, " -d -k ", defmapzipped))
system(paste("mv", defmaptemp, defmapfile))
system(paste0(gzip, " -d -k ", dilmaskzipped))
system(paste("mv", dilmasktemp, dilmaskfile))
system(paste0(gzip, " -d -k ", dilmapzipped))
system(paste("mv", dilmaptemp, dilmapfile))

# extract model data
model0file = "model0file.fits"
model1file = "model1file.fits"
modelmaptemp = strsplit(modelmapzipped, ".gz")[[1]]
modelmapfile = "modelmapfile.fits"
system(paste(funpack, "-O", model0file, model0zipped))
system(paste(funpack, "-O", model1file, model1zipped))
system(paste0(gzip, " -d -k ", modelmapzipped))
system(paste("mv", modelmaptemp, modelmapfile))

# data
xlo = round(xcen - ((xdim+1)/2))
xhi = round(xcen + ((xdim+1)/2))
ylo = round(ycen - ((ydim+1)/2))
yhi = round(ycen + ((ydim+1)/2))
simdat = read.fitsim(simfile, hdu=1)[xlo:xhi,ylo:yhi]
magdat = read.fitsim(defmapfile, hdu=2)[xlo:xhi,ylo:yhi]
dildat = read.fitsim(dilmaskfile, hdu=1)[xlo:xhi,ylo:yhi]
skyold = read.fitsim(defmapfile, hdu=3)[xlo:xhi,ylo:yhi]
dilskynew = read.fitsim(dilmapfile, hdu=3)[xlo:xhi,ylo:yhi]

# data model
maskdat = read.fitsim(defmapfile, hdu=1)[xlo:xhi,ylo:yhi]
model0dat = read.fitsim(model0file, hdu=1)[xlo:xhi,ylo:yhi]
model1dat = read.fitsim(model1file, hdu=1)[xlo:xhi,ylo:yhi]
modelskynew = read.fitsim(modelmapfile, hdu=3)[xlo:xhi,ylo:yhi]
resdat = simdat - model1dat

# png
png(file=paste0("mask_",codebase,".png"), width=8, height=7.45, units="in", res=255)
par("mar"=c(0.5,0.5,1.5,0.5))
par("oma"=c(0,0,0.5,0))

# par
layout(rbind(c(1,2,3,10),c(4,5,6,10),c(7,8,9,10)), widths=c(3,3,3,1))
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
image(1:537, 1:537, magdat, zlim=c(0.5,100), col=colmask, add=TRUE)
mtext(side=3, line=line, text="original image & seg. map")

aimage(fn(skyold), col.map=skycolmap, scale.type="lin", axes=FALSE, scale.lo=27, scale.hi=30, xlab="", ylab="", smooth.fwhm=0, col.invert=skycolinvert)
# aimage(skyold, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=0, col.invert=colinvert)
# contour(x=1:nrow(skyold), y=1:ncol(skyold), z=skyold, drawlabels=FALSE, add=TRUE, levels=c(ifn(magvals)), lty=magltys, lend=maglend, lwd=maglwd, col=magcols)
mtext(side=3, line=line, text="original background")

magcmap = 'topo'
aimage(magdat, col.map=magcmap, scale.type="lin", axes=FALSE, scale.lo=30, scale.hi=15, xlab="", ylab="", smooth.fwhm=0)
bgdat = magdat; bgdat[bgdat!=0] = NaN; image(x=1:nrow(magdat), y=1:ncol(magdat), bgdat, col='grey90', add=TRUE)
#rect(xl=1, xr=537, yb=1, yt=537, border="black")
mtext(side=3, line=line, text="magnitude map")
col.bar("bottom", horizontal=TRUE, n=4, col.map=magcmap, scale.lo=30, scale.hi=15, scale.type="lin", flip=TRUE, inset=-0.25, seg.num=499, seg.gap=0.25, seg.width=0.5)
#mtext(side=2, line=3.75, text=bquote(paste(m[r])), las=1)

aimage(simdat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=3, col.invert=colinvert)
image(1:537, 1:537, dildat, zlim=c(0.5,100), col=colmask, add=TRUE)
mtext(side=3, line=line, text="original image & dilated mask")

aimage(fn(dilskynew), col.map=skycolmap, scale.type="lin", axes=FALSE, scale.lo=27, scale.hi=30, xlab="", ylab="", smooth.fwhm=0, col.invert=skycolinvert)
# aimage(dilskynew, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=0, col.invert=colinvert)
# contour(x=1:nrow(dilskynew), y=1:ncol(dilskynew), z=dilskynew, drawlabels=FALSE, add=TRUE, levels=c(ifn(magvals)), lty=magltys, lend=maglend, lwd=maglwd, col=magcols)
mtext(side=3, line=line, text="background w. dilated mask")

aimage(model1dat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=0, col.invert=colinvert)
mtext(side=3, line=line, text="fitted model")

aimage(resdat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=3, col.invert=colinvert)
image(1:537, 1:537, maskdat, zlim=c(1.5,50000), col=col2hex(colmask,maskalpha), add=TRUE)
mtext(side=3, line=line, text="residual image & seg. map")

aimage(fn(modelskynew), col.map=skycolmap, scale.type="lin", axes=FALSE, scale.lo=27, scale.hi=30, xlab="", ylab="", smooth.fwhm=0, col.invert=skycolinvert)
# aimage(modelskynew, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=0, col.invert=colinvert)
# contour(x=1:nrow(modelskynew), y=1:ncol(modelskynew), z=modelskynew, drawlabels=FALSE, add=TRUE, levels=c(ifn(magvals)), lty=magltys, lend=maglend, lwd=maglwd, col=magcols)
mtext(side=3, line=line, text="background w. modelled mask")

# contour legend
plot(NA, xlim=c(0,1), ylim=c(0,1), axes=FALSE)
istep = 15
yoff = 0.175
linelen = 0.9
xpos = 0.45
count = 0
for(i in seq(max(magvals), min(magvals), len=9)){
    count = count + 1
    points(x=xpos, y=0+(count/istep)+yoff-0.03, pch=15, col=terrain.colors(9, rev=!skycolinvert)[count], cex=5)
    text(x=xpos, y=0+(count/istep)+yoff, lab=formatC(i, format='f', digits=1))
}
text(x=xpos, y=0+(count/istep)+yoff+0.075, lab=bquote(mu), cex=1.75)
# for(i in 1:length(magvals)){
#     if(abs(round(magvals[i])-magvals[i]) < 0.001){
#         text(x=xpos, y=0+(i/istep)+yoff, lab=formatC(magvals[i], format='f', digits=1))
#         lines(x=c((xpos-(linelen/2)),(xpos+(linelen/2))), y=c((0+(i/istep)+yoff-0.02),(0+(i/istep)+yoff-0.02)), lty=magltys[i], col=magcols[i], lwd=maglwd, lend=maglend)
#     }
# }
# text(x=xpos, y=0+(i/istep)+yoff+0.075, lab=bquote(mu), cex=1.75)

# finish up
unlink(c(simfile, defmapfile, dilmaskfile, dilmapfile, model0file, model1file, modelmapfile))
graphics.off()



# png
png(file=paste0("modmaskcomp_",codebase,".png"), width=8, height=8, units="in", res=255)
par("mar"=c(0.5,0.5,0.5,0.5))
par("oma"=c(0,1.5,1.5,0))

# par
layout(rbind(c(1,2),c(3,4)))
line = 0.25

aimage(model0dat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=0)
mtext(side=3, line=line, text="Source Extractor model image")
mtext(side=2, line=line, text="standard stretch")

aimage(model1dat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=0)
mtext(side=3, line=line, text="GalSim model image")

aimage(model0dat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo/10, scale.hi=zhi/10, xlab="", ylab="", smooth.fwhm=0)
mtext(side=2, line=line, text="narrow stretch")

aimage(model1dat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo/10, scale.hi=zhi/10, xlab="", ylab="", smooth.fwhm=0)

# finish up
graphics.off()
