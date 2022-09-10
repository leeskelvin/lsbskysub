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
codebase = "sex"
simzipped = paste0("../../sims/simdat/v5/calexp-HSC-R-8283-38.simulated-n4-a.fits.fz")
defmapzipped = paste0("../../source_extraction/",codebase,"_default/map/denlo4a.map.fits.gz")
model0zipped = paste0("../../source_extraction/",codebase,"_modelled/model/denlo4a.model0.fits.fz")
model1zipped = paste0("../../source_extraction/",codebase,"_modelled/model/denlo4a.model1.fits.fz")
modelmapzipped = paste0("../../source_extraction/",codebase,"_modelled/map/denlo4a.map.fits.gz")
fn = function(flux){-2.5*log10(flux/(0.168^2))+27}
ifn = function(mag){(10^(-0.4*(mag-27)))*(0.168^2)}
magvals = seq(29.5,27.0,by=-0.5)
magltys = c(1, 2, 3, 1, 2, 3)
magcols = c(8, 8, 8, 1, 1, 1)

# extract
simfile = "simfile.fits"
defmaptemp = strsplit(defmapzipped, ".gz")[[1]]
defmapfile = "defmapfile.fits"
model0file = "model0file.fits"
model1file = "model1file.fits"
modelmaptemp = strsplit(modelmapzipped, ".gz")[[1]]
modelmapfile = "modelmapfile.fits"
system(paste(funpack, "-O", simfile, simzipped))
system(paste0(gzip, " -d -k ", defmapzipped))
system(paste("mv", defmaptemp, defmapfile))
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
maskdat = read.fitsim(defmapfile, hdu=1)[xlo:xhi,ylo:yhi]
model0dat = read.fitsim(model0file, hdu=1)[xlo:xhi,ylo:yhi]
model1dat = read.fitsim(model1file, hdu=1)[xlo:xhi,ylo:yhi]
skyold = read.fitsim(defmapfile, hdu=3)[xlo:xhi,ylo:yhi]
skynew = read.fitsim(modelmapfile, hdu=3)[xlo:xhi,ylo:yhi]
resdat = simdat - model1dat

# png
png(file=paste0("modmask_",codebase,".png"), width=8, height=5, units="in", res=255)
par("mar"=c(0.5,0.5,1.5,0.5))
par("oma"=c(0,0,0.5,0))

# par
layout(rbind(c(1,3,5,7),c(2,4,6,7)), widths=c(3,3,3,1))
line = 0.25
colmap = "grey"
colinvert = FALSE
colmask = "hotpink"
maskalpha = 1

# plot
aimage(simdat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=3, col.invert=colinvert)
mtext(side=3, line=line, text="original image")

aimage(model1dat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=0, col.invert=colinvert)
mtext(side=3, line=line, text="fitted model")

aimage(simdat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=3, col.invert=colinvert)
image(1:537, 1:537, maskdat, zlim=c(1.5,50000), col=col2hex(colmask,maskalpha), add=TRUE)
mtext(side=3, line=line, text="original image & seg. map")

aimage(resdat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=3, col.invert=colinvert)
image(1:537, 1:537, maskdat, zlim=c(1.5,50000), col=col2hex(colmask,maskalpha), add=TRUE)
mtext(side=3, line=line, text="residual image & seg. map")

aimage(skyold, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=0, col.invert=colinvert)
contour(x=1:nrow(skyold), y=1:ncol(skyold), z=skyold, drawlabels=FALSE, add=TRUE, levels=c(ifn(magvals)), lty=magltys, lend="round", lwd=2, col=magcols)
mtext(side=3, line=line, text="original background")

aimage(skynew, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=0, col.invert=colinvert)
contour(x=1:nrow(skynew), y=1:ncol(skynew), z=skynew, drawlabels=FALSE, add=TRUE, levels=c(ifn(magvals)), lty=magltys, lend="round", lwd=2, col=magcols)
mtext(side=3, line=line, text="background w. modelled mask")

# contour legend
plot(NA, xlim=c(0,1), ylim=c(0,1), axes=FALSE)
istep = 10
yoff = 0.175
linelen = 0.9
xpos = 0.45
for(i in 1:length(magltys)){
    text(x=xpos, y=0+(i/istep)+yoff, lab=formatC(magvals[i], format='f', digits=1))
    lines(x=c((xpos-(linelen/2)),(xpos+(linelen/2))), y=c((0+(i/istep)+yoff-0.02),(0+(i/istep)+yoff-0.02)), lty=magltys[i], col=magcols[i], lwd=2, lend="round")
}
text(x=xpos, y=0+(i/istep)+yoff+0.075, lab=bquote(mu), cex=1.75)

# finish up
unlink(c(simfile, defmapfile, model0file, model1file, modelmapfile))
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
