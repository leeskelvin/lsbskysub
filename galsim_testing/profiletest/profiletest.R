#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
xcen = 151
ycen = 151
xx = 0:150
n = 4
lumtot = 10000
q = 0.5
re = 15
a = sqrt((re^2)/q)
lvls = 10^c(-3:2)
cols = grey((length(lvls)+1):1/(length(lvls)+1))[-1]
lwds = 2

# galsim
system("/usr/local/bin/galsim galsim.config")

# data
dat = read.fitsim("galsim.fits")
Ie = sersic.L2Ie(L=lumtot, n=n, re=re)
xy = expand.grid(-150:150, -150:150)
#s2d = matrix(sersic2d.xy(x=xy[,1], y=xy[,2], Ie=Ie, n=n, re=a, e=1-q, pa=0), nrow=301, ncol=301)
s2d = sersic2d(size=301, Ie=Ie, n=n, re=a, e=1-q, pa=0, norm=FALSE, discrete=TRUE)

# dev
pdf(file="profiletest.pdf", width=5, height=5)

# par
par("mar"=c(0,0,0,0))
par("oma"=c(4,4,1,1))
layout(rbind(c(2,2,2),c(2,1,2),c(2,2,2)), widths=c(5,5,0.5), heights=c(0.5,5,5))
palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))

# contour plot
contour(x=1:301-xcen, y=1:301-ycen, z=dat, levels=lvls, drawlabels=FALSE, axes=FALSE, xaxs="i", yaxs="i", col=cols, lwd=lwds, asp=1, lend=1, ljoin=1)
lines(x=range(xx), y=c(0,0), col=2, lwd=lwds, lend=1, ljoin=1)
abox()

# line plot
aplot(xx, dat[xcen+xx,ycen], type="l", log="y", col=1, lwd=lwds, las=1)
lines(xx, sersic1d(r=xx, Ie=Ie, n=n, re=a), col=2, lwd=lwds)
lines(xx, s2d[xcen+xx,ycen], col=5, lwd=lwds, lty=2, lend=1)
mtext(side=1, text="radius", line=1.75)
mtext(side=2, text="intensity", line=1.5)

# finish up
alegend("bottomleft", legend=c("GalSim","Sersic 1D","Sersic 2D"), type=list(l=list(lwd=lwds,col=1,lty=1,lend=1),l=list(lwd=lwds,col=2,lty=1,lend=1),l=list(lwd=lwds,col=5,lty=2,lend=1)))
graphics.off()

