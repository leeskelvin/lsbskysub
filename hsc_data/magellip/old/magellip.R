#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
datas = paste0("../../hsc_data/calexp/", grep(".dat", dir("../../hsc_data/calexp/"), value=TRUE))
pixelsize = 0.168

# data
dat1 = read.table(datas[1], stringsAsFactors=FALSE)
dat2 = read.table(datas[2], stringsAsFactors=FALSE)
dat = rbind(cbind(dat1,SOURCE=1), cbind(dat2,SOURCE=2))
colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS", "SOURCE")
if(any(dat[,"MAG_AUTO"] == 99)){dat = dat[-which(dat[,"MAG_AUTO"]==99),]}
dat[,"FLUX_RADIUS"] = dat[,"FLUX_RADIUS"] * pixelsize # now in arcsec
dat[,"MAG_AUTO"] = dat[,"MAG_AUTO"] + 27 # zero point correction
dat = dat[sample(x=nrow(dat)),] # randomise for plotting

# fits
radlo = dat[,"FLUX_RADIUS"]>=0.2 & dat[,"FLUX_RADIUS"]<=0.4
radmid = dat[,"FLUX_RADIUS"]>=0.4 & dat[,"FLUX_RADIUS"]<=0.6
radhi = dat[,"FLUX_RADIUS"]>=0.6 & dat[,"FLUX_RADIUS"]<=0.8
rads = list(radlo,radmid,radhi)
fits = {}
for(i in 1:length(rads)){
    mag = dat[rads[[i]],"MAG_AUTO"]
    ellip = dat[rads[[i]],"ELLIPTICITY"]
    fit = lm(mag~ellip)
    fit$coef[1] = -fit$coef[1] / fit$coef[2]
    fit$coef[2] = 1 / fit$coef[2]
    fit$coefficients = fit$coef
    fits = c(fits, list(fit))
}

# dev
pdf(file="magellip.pdf", width=5, height=5)

# par
par("mar"=c(3,3,3.5,3))

# plot
aplot(dat[radlo,"MAG_AUTO"], dat[radlo,"ELLIPTICITY"], dat[radlo,"FLUX_RADIUS"], pch=".", xlim=c(16,27.5), cex=2, cb=FALSE, scale.lo=0.2, scale.hi=0.8, col.map="topo", xlab="", ylab="", las=1, xnmin=1, side=c(1,2,4), bty="n", ynmin=1)
for(i in 1:length(fits)){
    abline(fits[[i]], col="white", lwd=5)
    abline(fits[[i]], col=topo.colors(7)[c(2,4,6)][i], lwd=2.5)
}
col.bar(x="top", horizontal=TRUE, seg.num=499, inset=-2.5, n=4, seg.gap=0.5, flip=TRUE, seg.width=1, scale.lo=0.2, scale.hi=0.8, col.map="topo")
abox(bty="u")
mtext(side=1, line=1.75, text=bquote(paste("apparent magnitude : ", m[r])))
mtext(side=2, line=1.75, text="ellipticity")
mtext(side=3, line=2.25, text=bquote(paste("half light radius : ", r[e], " / arcsec")))

# finish up
graphics.off()

