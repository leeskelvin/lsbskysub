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
#psfdat = psfdat / sum(psfdat)
psfdat = psfdat * 10^(-0.4*(20-27)) # ~20th mag star
psfdatxl = regrid(psfdat, fact=10) * 10*10

# lineprof

xx = yy = as.numeric(rownames(psfdatxl))-28
xy = cbind(expand.grid(xx,yy),as.numeric(psfdatxl))
if(any(xy[,3] < 0)){xy[(xy[,3]<0),3] = 0}
rad = round(sqrt((xy[,1]^2) + (xy[,2]^2)))
xy = cbind(xy,rad)
groups = split(xy[,3], xy[,4])
counts = as.numeric(lapply(groups, median))
rads = as.numeric(names(groups)) * 0.168

#xdim = ydim = 55
#xcen = ycen = (xdim+1)/2
#counts = rbind((psfdat[xcen,ycen:1]), (psfdat[xcen,ycen:ydim]), (psfdat[xcen:1,ycen]), (psfdat[xcen:xdim,ycen]))
#if(any(counts < 0)){counts[counts < 0] = 0}
#counts = apply(counts, 2, median, na.rm=TRUE)
#rads = 0:(length(counts)-1) * 0.168

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
scalelen = 2.5

aimage(sampdat, col.map="sls", scale.type="asinh", scale.lo=zlo, scale.hi=zhi, xlo=1, ylo=1, xdim=9*size, ydim=3*size, smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab=""); abline(h=seq(1,1000,by=size), col=linecol, lwd=linewd); abline(v=seq(1,1000,by=size), col=linecol, lwd=linewd); box(col="white", lwd=3)
label("topleft", lab="Point Source Samples", col="white", cex=cextext, inset=insettext)

aimage(psfdat, col.map="sls", scale.type="asinh", scale.lo=zlo, scale.hi=zhi, smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab="", xdim=size, ydim=size, padvalue=0); box(col="white", lwd=3)
label("topleft", lab="PSF", col="white", cex=cextext, inset=insettext)
lines(x=c((par("usr")[2]-insetscale),((par("usr")[2]-insetscale-(scalelen/0.168)))), y=rep(par("usr")[3]+insetscale,2), lwd=5, lend=3, col="white")
text(x=(par("usr")[2]-insetscale), y=(par("usr")[3]+insetscale+2), lab=paste(scalelen, "arcsec"), col="white", adj=c(1,0), cex=1.25)

aimage(residdat, col.map="sls", scale.type="asinh", scale.lo=zlo, scale.hi=zhi, xlo=1, ylo=1, xdim=9*size, ydim=3*size, smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab=""); abline(h=seq(1,1000,by=size), col=linecol, lwd=linewd); abline(v=seq(1,1000,by=size), col=linecol, lwd=linewd); box(col="white", lwd=3)
label("topleft", lab="Residuals", col="white", cex=cextext, inset=insettext)

# line plot
par("mar"=c(4.1,4.1,1,0.5))
aplot(rads, sbs, type="n", xlim=c(0,5), ylim=c(30,19.5), xlab=bquote(paste("radius / arcsec")), ylab=bquote(paste(mu, " / mag ", arcsec^{-2})), las=1, cex.lab=1.25, axes=FALSE)
shade(rads, sbslo, sbshi, col="#f1a340")

## gaussian
#cdat = counts; cdat[cdat == 0] = NA
#err = sqrt(cdat+0.001)
#gfit = fit(data=cdat, par=list(I0=c(1,2,3), fwhm=c(1,2,3)), fn=gauss1d, arg=list(r=rads), sigma=err, method="BFGS")
#yval = -2.5*log10(gauss1d(r=rads, I0=gfit$par$I0, fwhm=gfit$par$fwhm) / (0.168^2)) + 27
#lines(rads, yval, col="red", lwd=5)

# moffat
cdat = counts; cdat[rads>3.5] = NA
#err = sqrt(errs[,"ERR95LO"]^2 + errs[,"ERR95HI"]^2)
err = sqrt(cdat)
mfit = fit(data=cdat, par=list(I0=c(20), beta=c(2), fwhm=c(0.6)), fn=moffat1d, arg=list(r=rads), sigma=err, method="BFGS", lower=c(0,0,0))
yval = -2.5*log10(moffat1d(r=seq(0,max(rads),len=1001), I0=mfit$par$I0, beta=mfit$par$beta, fwhm=mfit$par$fwhm) / (0.168^2)) + 27
lines(seq(0,max(rads),len=1001), yval, col="#998ec3", lwd=2.5)

## sersic
#cdat = counts; cdat[cdat == 0] = NA
#err = sqrt(cdat+0.001)
#sfit = fit(data=cdat, par=list(Ie=c(1,2,3), n=c(1,2,3), re=c(1,2,3)), fn=sersic1d, arg=list(r=rads), sigma=err, method="L-BFGS-B", lower=0)
#yval = -2.5*log10(sersic1d(r=rads, Ie=sfit$par$Ie, n=sfit$par$n, re=sfit$par$re) / (0.168^2)) + 27
#lines(rads, yval, col="blue", lwd=5)

# line data
lines(rads, sbs, type="p", pch=16, col="white", cex=1.5)
lines(rads, sbs, type="p", pch=16, col="black", lwd=2, lend=3)
#legend("topright", fill=c("#f1a340",NA), bty="n", legend=c("95% CI",paste0("Moffat (Γ = ", formatC(mfit$par$fwhm,format="f",digits=2), ", β = ", formatC(mfit$par$beta,format="f",digits=2), ")")), cex=1.25, inset=0.05, border=c("#f1a340",NA), lty=c(NA,1), lwd=c(NA,5), col=c(NA,"#998ec3"), merge=TRUE, xjust=1, seg.len=c(1.25,2))
legend("topright", fill="#f1a340", bty="n", legend="95% CI", cex=1.25, inset=c(0.05,0.15), border="#f1a340")
legend("topright", col="#998ec3", lty=1, lwd=2.5, bty="n", legend=paste0("Moffat: Γ = ", formatC(mfit$par$fwhm,format="f",digits=2), ", β = ", formatC(mfit$par$beta,format="f",digits=2)), cex=1.25, inset=0.05)
box(col="grey75"); aaxes(las=1)

# finish up
graphics.off()
unlink(c(samp,resid))

