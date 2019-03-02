#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)

# definitions
datas = paste0("../../hsc_data/calexp/", grep(".dat", dir("../../hsc_data/calexp/"), value=TRUE))
magbright = 22
magfaint = 25
magend = 30
bw = 0.5
pixelsize = 0.168

# data
dat1 = read.table(datas[1], stringsAsFactors=FALSE)
dat2 = read.table(datas[2], stringsAsFactors=FALSE)
dat = rbind(dat1, dat2)
colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS")

# samples
main = which(dat[,"MAG_AUTO"]+27 >= magbright+bw/2)
toobright = which(dat[,"MAG_AUTO"]+27 <= magbright+bw/2)

# fit
fn = function(x, a, b){return(a + b*x)}
#err = sqrt(dat[main,"FLUX_RADIUS"]+1)
err = abs(dat[main,"MAG_AUTO"]+27-28)
fitdat = fit(dat[main,"FLUX_RADIUS"]*pixelsize, par=list(a=1, b=1), fn=fn, arg=list(x=dat[main,"MAG_AUTO"]+27), sigma=err, method="BFGS")
xx = seq(10,50,len=100)
yy = fn(x=xx, a=fitdat$par$a, b=fitdat$par$b)

# dev
cairo_pdf(file="magradii.pdf", width=5, height=5)
par("mar"=c(4,4,1,4))

# plot
aplot(NA, xlim=c(16,28), ylim=c(0.11,3), log="y", xlab=bquote(paste("apparent magnitude : ", m[r])), ylab=bquote(paste("half light radius : ", r[e], " / arcsec")), las=1, xnmin=1, axes=FALSE)
points(dat[main,"MAG_AUTO"]+27, dat[main,"FLUX_RADIUS"]*pixelsize, pch=".", cex=2, col=acol("black",0.5))
points(dat[toobright,"MAG_AUTO"]+27, dat[toobright,"FLUX_RADIUS"]*pixelsize, pch=".", cex=2, col=acol("red",0.5))
lines(xx,yy,col="blue", lwd=3)
aaxes(side=1:3, xnmin=1)
aaxis(side=4, 

# finish up
graphics.off()





