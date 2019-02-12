#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)

# definitions
funpack = "/usr/bin/funpack"
inbase = "calexp-HSC-R-8283-38"
sampfz = paste0(inbase, ".pssample-55.fits.fz")
residfz = paste0(inbase, ".psresid-55.fits.fz")
samp = paste0(inbase, ".pssample.fits")
resid = paste0(inbase, ".psresid.fits")
psf = paste0(inbase, ".psf.fits")
size = 55 # vignette size in samp/resid

# setup
system(paste0(funpack, " -O ", samp, " ", sampfz))
system(paste0(funpack, " -O ", resid, " ", residfz))

# data
errs = read.csv("skyerr.csv")
sampdat = read.fitsim(samp)
residdat = read.fitsim(resid)
psfdat = read.fitsim(psf)

# psf norm
psfdat = psfdat / sum(psfdat)
psfdat = psfdat * 10^(-0.4*(20-27)) # ~20th mag star

# lineprof
xdim = ydim = 55
xcen = ycen = (xdim+1)/2
counts = rbind((psfdat[xcen,ycen:1]), (psfdat[xcen,ycen:ydim]), (psfdat[xcen:1,ycen]), (psfdat[xcen:xdim,ycen]))
counts = apply(counts, 2, median)
rads = 1:size * 0.168
sbs = sbslo = sbshi = rep(50, length(rads))
sbs[1:length(counts)] = suppressWarnings(-2.5 * log10(counts / (0.168^2)) + 27)
sbslo[1:length(counts)] = suppressWarnings(-2.5 * log10((counts+errs[,"ERR95LO"]) / (0.168^2)) + 27)
sbshi[1:length(counts)] = suppressWarnings(-2.5 * log10((counts+errs[,"ERR95HI"]) / (0.168^2)) + 27)
if(any(is.na(sbs))){sbs[is.na(sbs)] = 50}
if(any(is.na(sbslo))){sbslo[is.na(sbslo)] = 50}
if(any(is.na(sbshi))){sbshi[is.na(sbshi)] = 50}

# dev
png(file="psfcheck.png", width=8, height=8, units="in", res=300)
par("mar"=c(0,0,0,0))
layout(rbind(rep(1,18),c(0,rep(2,6),0,rep(4,9),0),rep(3,18)))

# plot
linecol = "grey75"
linewd = 2
fwhm = 1
zlo = 1*-0.07
zhi = 15*0.07
cextext = 2
insettext = c(0.5,0.5)
insetscale = 3
scalelen = 5

aimage(sampdat, col.map="sls", scale.type="asinh", scale.lo=zlo, scale.hi=zhi, xlo=1, ylo=1, xdim=9*size, ydim=3*size, smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab=""); abline(h=seq(1,1000,by=size), col=linecol, lwd=linewd); abline(v=seq(1,1000,by=size), col=linecol, lwd=linewd); box(col="white", lwd=3)
label("topleft", lab="Point Source Samples", col="white", cex=cextext, inset=insettext)

aimage(psfdat, col.map="sls", scale.type="asinh", scale.lo=zlo, scale.hi=zhi, smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab="", xdim=size, ydim=size, padvalue=0); box(col="white", lwd=3)
label("topleft", lab="PSF", col="white", cex=cextext, inset=insettext)
lines(x=c((par("usr")[2]-insetscale),((par("usr")[2]-insetscale-(scalelen/0.168)))), y=rep(par("usr")[3]+insetscale,2), lwd=5, lend=3, col="white")
text(x=(par("usr")[2]-insetscale), y=(par("usr")[3]+insetscale+2), lab=paste(scalelen, "arcsec"), col="white", adj=c(1,0), cex=1.25)

aimage(residdat, col.map="sls", scale.type="asinh", scale.lo=zlo, scale.hi=zhi, xlo=1, ylo=1, xdim=9*size, ydim=3*size, smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab=""); abline(h=seq(1,1000,by=size), col=linecol, lwd=linewd); abline(v=seq(1,1000,by=size), col=linecol, lwd=linewd); box(col="white", lwd=3)
label("topleft", lab="Residuals", col="white", cex=cextext, inset=insettext)

par("mar"=c(4.1,4.1,1,0.5))
aplot(rads, sbs, type="n", xlim=c(0,5), ylim=c(30,19.5), xlab=bquote(paste("radius / arcsec")), ylab=bquote(paste(mu, " / mag ", arcsec^{-2})), las=1, cex.lab=1.25, axes=FALSE)
shade(rads, sbslo, sbshi, col="#f1a340")
lines(rads, sbs, type="b", pch=16, col="black")
legend("topright", fill="#f1a340", bty="n", legend="95% CI", cex=1.25, inset=0.05, border="#f1a340")
box(col="grey75"); aaxes(las=1)

# finish up
graphics.off()
unlink(c(samp,resid))

