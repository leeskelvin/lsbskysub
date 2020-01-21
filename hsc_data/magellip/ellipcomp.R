#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
datas = paste0("../../hsc_data/calexp/", grep(".dat", dir("../../hsc_data/calexp/"), value=TRUE))
sims = paste0("../../sims/cat-input/", grep("-n1-b.dat", dir("../../sims/cat-input/"), value=TRUE))
dat1 = read.table(datas[1], stringsAsFactors=FALSE)
dat2 = read.table(datas[2], stringsAsFactors=FALSE)
dat = rbind(cbind(dat1,SOURCE=1), cbind(dat2,SOURCE=2))
colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS", "SOURCE")
sim1 = read.table(sims[1], stringsAsFactors=FALSE)
sim2 = read.table(sims[2], stringsAsFactors=FALSE)
sim = rbind(cbind(sim1,SOURCE=1), cbind(sim2,SOURCE=2))
colnames(sim) = c("X", "Y", "FLUX", "HALF_LIGHT_RADIUS", "Q", "THETA", "N", "STAMP_SIZE", "SOURCE")
dellip = dat[,"ELLIPTICITY"]
sellip = 1 - sim[,"Q"]

# dev
pdf(file="ellipcomp.pdf", width=5, height=5)

# par
par("mar"=c(3,3.5,0.5,0.5))
palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
breaks = seq(0,1,by=0.05)
alpha = 0.5
par("lwd"=2.5)
par("ljoin"=1)

# plot
hist(dellip, axes=FALSE, breaks=breaks, freq=T, xlab="", ylab="", col=col2hex(2,alpha), border="white", main="")
hist(sellip, breaks=breaks, freq=T, add=T, col=NA, border=col2hex(3,1))
aaxes(side=c(1,2,3,4), labels=c(1,2), xnmin=3, ynmin=4, las=1)
abox()
mtext(side=1, text="ellipticity", line=1.75)
mtext(side=2, text="number frequency", line=2.25)
alegend("topright", legend=c("observed","simulated (bright only)"), type=list(f=list(col=col2hex(2,alpha),border="white"),f=list(col="white",border=col2hex(3,1))))

# finish up
graphics.off()

