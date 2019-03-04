#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000","#f1a340","#998ec3","#edf8b1","#7fcdbb","#2c7fb8"))
set.seed(3125)

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
if(any(dat[,"MAG_AUTO"] == 99)){dat = dat[-which(dat[,"MAG_AUTO"]==99),]}
attach(dat)
FLUX_RADIUS = FLUX_RADIUS * pixelsize # arcsec
MAG_AUTO = MAG_AUTO + 27 # zero point correction

# samples
main = which(MAG_AUTO >= magbright+bw/2)
toobright = which(MAG_AUTO <= magbright+bw/2)

# fit
fit = lm(FLUX_RADIUS[main] ~ MAG_AUTO[main])

# dev
cairo_pdf(file="magradii.pdf", width=5, height=4.5)
par("mar"=c(3.5,3.5,1,3.5))

# plot
palette(c("#000000","#f1a340","#998ec3","#edf8b1","#7fcdbb","#2c7fb8"))
aplot(NA, xlim=c(16,28), ylim=c(0.11,3), log="y", xlab=bquote(paste("apparent magnitude : ", m[r])), ylab=bquote(paste("half light radius : ", r[e], " / arcsec")), las=1, xnmin=1, axes=FALSE, mgp=c(1.75,0.25,0))
points(MAG_AUTO[main], FLUX_RADIUS[main], pch=".", cex=2, col=col2rgba(1,0.5))
points(MAG_AUTO[toobright], FLUX_RADIUS[toobright], pch=".", cex=2, col=col2rgba(2,0.5))



lines(xx,yy,col="blue", lwd=3)
aaxes(side=1:3, xnmin=1, las=1)
aaxis(side=4, fn=function(x){x/pixelsize}, las=1)
abox()
mtext(side=4, line=1.75, text=bquote(paste(r[e], " / pixel")))

# finish up
graphics.off()





