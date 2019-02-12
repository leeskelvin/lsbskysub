#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)

# definitions
funpack = "/usr/bin/funpack"
inbase = "calexp-HSC-R-8283-38"
sampfz = paste0(inbase, ".pssample.fits.fz")
residfz = paste0(inbase, ".psresid.fits.fz")
samp = paste0(inbase, ".pssample.fits")
resid = paste0(inbase, ".psresid.fits")
psf = paste0(inbase, ".psf.fits")
size = 101 # vignette size in samp/resid

# setup
system(paste0(funpack, " -O ", samp, " ", sampfz))
system(paste0(funpack, " -O ", resid, " ", residfz))

# data
sampdat = read.fitsim(samp)
residdat = read.fitsim(resid)
psfdat = read.fitsim(psf)

# psf norm
psfdat = psfdat / sum(psfdat)
psfdat = psfdat * 10^(-0.4*(20-27)) # ~20th mag star

# sky error
skydat = residdat
skydat[abs(skydat) < 0.01] = NA
means = {}
n = 100
for(i in 1:n){
    temp = sample(x=residdat, size=length(residdat), replace=TRUE)
    means = c(means, mean(temp))
}




xx = seq(1, dim(residdat)[1], by=101)
yy = seq(1, dim(residdat)[2], by=101)
rad = 5
means = {}
for(i in 1:length(xx)){
    for(j in 1:length(yy)){
        ijdat = residdat[
            (max(c(1, xx[i]-rad))):(min(c(dim(residdat)[1], xx[i]+rad)))
            ,(max(c(1, yy[i]-rad))):(min(c(dim(residdat)[2], yy[i]+rad)))
            ]
        means = c(means, mean(ijdat))
    }
}
skyerr = sd(means)

# lineprof
xdim = ydim = 55
xcen = ycen = (xdim+1)/2
counts = rbind((psfdat[xcen,ycen:1]), (psfdat[xcen,ycen:ydim]), (psfdat[xcen:1,ycen]), (psfdat[xcen:xdim,ycen]))
counts = apply(counts, 2, median)
rads = 1:101 * 0.168
sbs = sbslo = sbshi = rep(50, length(rads))
sbs[1:length(counts)] = suppressWarnings(-2.5 * log10(counts / (0.168^2)) + 27)
sbslo[1:length(counts)] = suppressWarnings(-2.5 * log10((counts-skyerr) / (0.168^2)) + 27)
sbshi[1:length(counts)] = suppressWarnings(-2.5 * log10((counts+skyerr) / (0.168^2)) + 27)
if(any(is.na(sbs))){sbs[is.na(sbs)] = 50}
if(any(is.na(sbslo))){sbslo[is.na(sbslo)] = 50}
if(any(is.na(sbshi))){sbshi[is.na(sbshi)] = 50}

# dev
png(file="psfcheck.png", width=8, height=8, units="in", res=300)
par("mar"=c(0,0,0,0))
layout(rbind(c(1,1,1,1,1,1,1,1,1),c(0,2,2,2,4,4,4,4,0),c(3,3,3,3,3,3,3,3,3)))

# plot
linecol = "grey75"
linewd = 3
fwhm = 1
zlo = 1*-0.07
zhi = 15*0.07
aimage(sampdat, col.map="sls", scale.type="asinh", scale.lo=zlo, scale.hi=zhi, xlo=1, ylo=1, xdim=3*101, ydim=9*101, smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab=""); abline(h=seq(1,1000,by=101), col=linecol, lwd=linewd); abline(v=seq(1,1000,by=101), col=linecol, lwd=linewd); box(col="white", lwd=3)

aimage(psfdat, col.map="sls", scale.type="asinh", scale.lo=zlo, scale.hi=zhi, smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab="", xdim=101, ydim=101, padvalue=0); box(col="white", lwd=3)

aimage(residdat, col.map="sls", scale.type="asinh", scale.lo=zlo, scale.hi=zhi, xlo=1, ylo=1, xdim=3*101, ydim=9*101, smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab=""); abline(h=seq(1,1000,by=101), col=linecol, lwd=linewd); abline(v=seq(1,1000,by=101), col=linecol, lwd=linewd); box(col="white", lwd=3)

aplot(rads, sbs, type="n", xlim=c(0,4.5), ylim=c(30,19.5), xlab=bquote(paste("radius / arcsec")), ylab=bquote(paste(mu, " / mag ", arcsec^{-2})), las=1)
shade(rads, sbslo, sbshi, col="#f1a340")
lines(rads, sbs, type="b", pch=16, col="black")

# finish up
graphics.off()
unlink(c(samp,resid))

