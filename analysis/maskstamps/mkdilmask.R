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
dilmaskzipped = paste0("../../source_extraction/",codebase,"_dilated/mask/denlo4a.mask.fits.gz")
dilmapzipped = paste0("../../source_extraction/",codebase,"_dilated/map/denlo4a.map.fits.gz")
# modelmaskzipped = paste0("../../source_extraction/",codebase,"_modelled/model/denlo4a.model1.mask.fits.fz")
fn = function(flux){-2.5*log10(flux/(0.168^2))+27}
ifn = function(mag){(10^(-0.4*(mag-27)))*(0.168^2)}
magvals = seq(29.5,27.0,by=-0.5)
magltys = c(1, 2, 3, 1, 2, 3)
magcols = c(8, 8, 8, 1, 1, 1)

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

# data
xlo = round(xcen - ((xdim+1)/2))
xhi = round(xcen + ((xdim+1)/2))
ylo = round(ycen - ((ydim+1)/2))
yhi = round(ycen + ((ydim+1)/2))
simdat = read.fitsim(simfile, hdu=1)[xlo:xhi,ylo:yhi]
magdat = read.fitsim(defmapfile, hdu=2)[xlo:xhi,ylo:yhi]
dildat = read.fitsim(dilmaskfile, hdu=1)[xlo:xhi,ylo:yhi]
skyold = read.fitsim(defmapfile, hdu=3)[xlo:xhi,ylo:yhi]
skynew = read.fitsim(dilmapfile, hdu=3)[xlo:xhi,ylo:yhi]

# png
png(file=paste0("dilmask_",codebase,".png"), width=8, height=5, units="in", res=255)
par("mar"=c(0.5,0.5,1.5,0.5))
par("oma"=c(0,0,0.5,0))

# par
layout(rbind(c(1,3,5,7),c(2,4,6,7)), widths=c(3,3,3,1))
line = 0.25
colmap = "grey"
colinvert = FALSE
colmask = "hotpink"

# plot
aimage(simdat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=3, col.invert=colinvert)
mtext(side=3, line=line, text="original image")

aimage(magdat, col.map="sls", scale.type="lin", axes=FALSE, scale.lo=30, scale.hi=15, xlab="", ylab="", smooth.fwhm=0)
bgdat = magdat; bgdat[bgdat!=0] = NaN; image(x=1:nrow(magdat), y=1:ncol(magdat), bgdat, col='grey90', add=TRUE)
#rect(xl=1, xr=537, yb=1, yt=537, border="black")
mtext(side=3, line=line, text="magnitude map")
col.bar("bottom", horizontal=TRUE, n=4, col.map="sls", scale.lo=30, scale.hi=15, scale.type="lin", flip=TRUE, inset=-0.25, seg.num=499, seg.gap=0.25, seg.width=0.5)
#mtext(side=2, line=3.75, text=bquote(paste(m[r])), las=1)

aimage(simdat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=3, col.invert=colinvert)
image(1:537, 1:537, magdat, zlim=c(0.5,100), col=colmask, add=TRUE)
mtext(side=3, line=line, text="original image & seg. map")

aimage(simdat, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=3, col.invert=colinvert)
image(1:537, 1:537, dildat, zlim=c(0.5,100), col=colmask, add=TRUE)
mtext(side=3, line=line, text="original image & dilated mask")

aimage(skyold, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=0, col.invert=colinvert)
contour(x=1:nrow(skyold), y=1:ncol(skyold), z=skyold, drawlabels=FALSE, add=TRUE, levels=c(ifn(magvals)), lty=magltys, lend="round", lwd=2, col=magcols)
mtext(side=3, line=line, text="original background")

aimage(skynew, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=0, col.invert=colinvert)
contour(x=1:nrow(skynew), y=1:ncol(skynew), z=skynew, drawlabels=FALSE, add=TRUE, levels=c(ifn(magvals)), lty=magltys, lend="round", lwd=2, col=magcols)
mtext(side=3, line=line, text="background w. dilated mask")

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
unlink(c(simfile, defmapfile, dilmaskfile, dilmapfile))
graphics.off()
