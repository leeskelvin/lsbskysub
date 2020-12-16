#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000","#f1a340","#998ec3","#edf8b1","#7fcdbb","#2c7fb8"))
set.seed(3125)

# definitions
datas = paste0("../../hsc_data/calexp/", grep(".dat", dir("../../hsc_data/calexp/"), value=TRUE))
pixelsize = 0.168
starthresh = 0.05

# data
dat1 = read.table(datas[1], stringsAsFactors=FALSE)
dat2 = read.table(datas[2], stringsAsFactors=FALSE)
dat = rbind(cbind(dat1,SOURCE=1), cbind(dat2,SOURCE=2))
colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS", "SOURCE")
if(any(dat[,"MAG_AUTO"] == 99)){dat = dat[-which(dat[,"MAG_AUTO"]==99),]}
dat[,"FLUX_RADIUS"] = dat[,"FLUX_RADIUS"] * pixelsize # now in arcsec
dat[,"MAG_AUTO"] = dat[,"MAG_AUTO"] + 27 # zero point correction
cat("\nRemoved due to star-like : ", length(which(dat[,"CLASS_STAR"] > starthresh)), "/", nrow(dat), "\n")
dat = dat[dat[,"CLASS_STAR"]<=starthresh,] # remove probable stars
dat = dat[sample(x=nrow(dat)),] # randomise for plotting

# fit
aa = 2.8
bb = -0.1
b = -0.15
# good = which(dat[,"MAG_AUTO"] >= 22.25 & dat[,"FLUX_RADIUS"] >= aa + bb*dat[,"MAG_AUTO"])
good = which(dat[,"FLUX_RADIUS"] >= aa + bb*dat[,"MAG_AUTO"])
x = dat[good,"MAG_AUTO"]
y = dat[good,"FLUX_RADIUS"]
fit = lm(y ~ 1 + offset(b*x)); fit$coef = cbind(fit$coef[1],b); fit$coef[1]=4.25
xx = seq(15,(0.01-fit$coef[1])/fit$coef[2],len=1001)
#yy = predict(fit, newdata=data.frame(x=xx), interval="confidence", level=0.99)
yy = data.frame((fit$coef[2] * xx) + fit$coef[1])
px = c(seq(15,(0.01-aa)/bb,len=101),15)
py = c((aa+bb*seq(15,(0.01-aa)/bb,len=101)),0.01)
zone = 0.25 # shaded region
alpha = 0.5
pch = '.'

# dev
pdf(file="magradii.pdf", width=5, height=4.5)
par("mar"=c(3,3,1,3))

# plot
palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
aplot(NA, xlim=c(18.5,27.5), ylim=c(0.18,2.5), log="y", xlab=NA, ylab=NA, las=1, xnmin=1, axes=FALSE)
#apolygon(x=px, y=py, lend=1, ljoin=1, col=col2hex(3,0.5), border=col2hex(3,0.5), lwd=2, density=10)
points(dat[,"MAG_AUTO"], dat[,"FLUX_RADIUS"], pch=pch, cex=0.2, col=col2hex(dat[,"SOURCE"]+1,alpha))
shade(x=xx, ylo=yy[,1]-zone*yy[,1], yhi=yy[,1]+zone*yy[,1], col=col2hex(1,0.25), border=1, lty=2, lend=1)
lines(xx, yy[,1], col=1, lwd=2.5)
alegend("bottomleft", inset=0.5, bg=NA, bty="o", box.col=NA, legend=c("low density data", "high density data", bquote(paste(r[e], " = ", .(fit$coef[2]), m[r], " + ", .(formatC(fit$coef[1],format="f",digits=2)))), paste0("trendline ± ",zone*100,"%")), type=list(p=list(pch=pch,cex=5,col=2), p=list(pch=pch,cex=5,col=3), l=list(col=col2hex(1), lwd=2.5, lend=1), f=list(col=col2hex(1,0.25), border=1, lty=2, lend=1)), cex=0.75)
aaxes(side=1:3, xnmin=3, las=1)
aaxis(side=4, fn=function(x){x/pixelsize}, las=1)
abox()
mtext(side=1, line=1.75, text=bquote(paste("apparent magnitude : ", m[r])))
mtext(side=2, line=1.25, text=bquote(paste("half light radius : ", r[e], " / arcsec")))
mtext(side=4, line=1.25, text=bquote(paste(r[e], " / pixel")))

# finish up
graphics.off()





