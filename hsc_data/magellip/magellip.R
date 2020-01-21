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
starthresh = 0.05 #0.0285
cat("\nRemoved due to star-like : ", length(which(dat[,"CLASS_STAR"] > starthresh)), "/", nrow(dat), "\n")
dat = dat[dat[,"CLASS_STAR"]<=starthresh,] # remove probable stars
dat = dat[sample(x=nrow(dat)),] # randomise for plotting

# loop
bw = 0.5
mags = seq(16.5, 27.5, by=bw)
e1s = e2s = e3s = e4s = n1s = n2s = n3s = n4s = rep(NA,length(mags))
for(i in 1:length(mags)){
    samp = which(dat[,"MAG_AUTO"] >= mags[i]-bw/2 & dat[,"MAG_AUTO"] <= mags[i]+bw/2)
    irad = dat[samp,"FLUX_RADIUS"]
    iellip = dat[samp,"ELLIPTICITY"]
#    imag = dat[samp,"MAG_AUTO"]
#    radmid = (-0.15 * imag) + 4.25
#    radlo = radmid - 0.25*radmid
#    radlomid = radmid - 0.125*radmid
#    radhimid = radmid + 0.125*radmid
#    radhi = radmid + 0.25*radmid
#    radid = numeric(length(irad))
#    if(any(irad >= radlo & irad <= radlomid)){radid[irad >= radlo & irad <= radlomid] = 1}
#    if(any(irad >= radlomid & irad <= radmid)){radid[irad >= radlomid & irad <= radmid] = 2}
#    if(any(irad >= radmid & irad <= radhimid)){radid[irad >= radmid & irad <= radhimid] = 3}
#    if(any(irad >= radhimid & irad <= radhi)){radid[irad >= radhimid & irad <= radhi] = 4}
#    e1 = e2 = e3 = e4 = 0 # default to circular
#    if(sum(radid==1) > 0){e1 = iellip[radid==1]}
#    if(sum(radid==2) > 0){e2 = iellip[radid==2]}
#    if(sum(radid==3) > 0){e3 = iellip[radid==3]}
#    if(sum(radid==4) > 0){e4 = iellip[radid==4]}
#    radlos[i] = ((-0.15 * mags[i]) + 4.25) - 0.25*((-0.15 * mags[i]) + 4.25)
#    radhis[i] = ((-0.15 * mags[i]) + 4.25) + 0.25*((-0.15 * mags[i]) + 4.25)
    if(length(irad) >= 0){
        qrad = quantile(irad)
        e1 = iellip[irad >= qrad[1] & irad <= qrad[2]]
        e2 = iellip[irad >= qrad[2] & irad <= qrad[3]]
        e3 = iellip[irad >= qrad[3] & irad <= qrad[4]]
        e4 = iellip[irad >= qrad[4] & irad <= qrad[5]]
        e1s[i] = median(e1)
        e2s[i] = median(e2)
        e3s[i] = median(e3)
        e4s[i] = median(e4)
        n1s[i] = length(e1)
        n2s[i] = length(e2)
        n3s[i] = length(e3)
        n4s[i] = length(e4)
    }
}

# 2D fit
xyz = expand.grid(x=mags, y=1:4)
xyz = cbind(xyz, z=c(e1s,e2s,e3s,e4s), num=c(n1s,n2s,n3s,n4s))
if(any(is.na(xyz[,"z"]))){xyz = xyz[-which(is.na(xyz[,"z"])),]}
fitxyz = xyz
numthresh = 25
cat("\nRemoved due to low # sampling : ", sum(xyz[which(xyz[,"num"]<=numthresh),"num"]), "/", nrow(dat), "\n")
fitxyz = fitxyz[-which(xyz[,"num"]<=numthresh),] # should low density patches be ignored?
x = fitxyz[,"x"]
y = fitxyz[,"y"]
z = fitxyz[,"z"]
fit = lm(z ~ y + x + I(x^2)); print(fit)
uvw = expand.grid(x=mags, y=1:4)
uvw = cbind(uvw, z = fit$coef[1] + fit$coef[2]*uvw[,"y"] + fit$coef[3]*uvw[,"x"] + fit$coef[4]*uvw[,"x"]^2)
colnames(uvw) = c("MAG", "QRAD", "ELLIP")

lomag = min(xyz[which(xyz[,"num"]>numthresh & xyz[,"y"]==1),"x"])
himag = max(xyz[which(xyz[,"num"]>numthresh & xyz[,"y"]==1),"x"])
loq1 = which(xyz[,"num"]<=numthresh & xyz[,"y"]==1 & xyz[,"x"]<lomag)
hiq1 = which(xyz[,"num"]<=numthresh & xyz[,"y"]==1 & xyz[,"x"]>himag)
uvw[loq1,"ELLIP"] = uvw[which(uvw[,"MAG"]==lomag & uvw[,"QRAD"]==1),"ELLIP"]
uvw[loq1+0.25*nrow(uvw),"ELLIP"] = uvw[which(uvw[,"MAG"]==lomag & uvw[,"QRAD"]==2),"ELLIP"]
uvw[loq1+0.50*nrow(uvw),"ELLIP"] = uvw[which(uvw[,"MAG"]==lomag & uvw[,"QRAD"]==3),"ELLIP"]
uvw[loq1+0.75*nrow(uvw),"ELLIP"] = uvw[which(uvw[,"MAG"]==lomag & uvw[,"QRAD"]==4),"ELLIP"]
uvw[hiq1,"ELLIP"] = uvw[which(uvw[,"MAG"]==himag & uvw[,"QRAD"]==1),"ELLIP"]
uvw[hiq1+0.25*nrow(uvw),"ELLIP"] = uvw[which(uvw[,"MAG"]==himag & uvw[,"QRAD"]==2),"ELLIP"]
uvw[hiq1+0.50*nrow(uvw),"ELLIP"] = uvw[which(uvw[,"MAG"]==himag & uvw[,"QRAD"]==3),"ELLIP"]
uvw[hiq1+0.75*nrow(uvw),"ELLIP"] = uvw[which(uvw[,"MAG"]==himag & uvw[,"QRAD"]==4),"ELLIP"]

oo = order(uvw[,1])
uvw = uvw[oo,]
write.csv(uvw, file="magellip.csv", row.names=FALSE, quote=FALSE)

# dev
pdf(file="magellip.pdf", width=8, height=4.25)

# par
layout(rbind(1,2))
par("mar"=c(0,0.75,0,0.75))
par("oma"=c(3,3.5,3,0))
col.map = "topo"
scale.lo = 0.15
scale.hi = 0.45
cbn = 4
cbseg = 499
cex = 3.7

# plot
aplot(xyz[,1], xyz[,2], xyz[,3], pch=15, scale.lo=scale.lo, scale.hi=scale.hi, col.map=col.map, cex=cex, xlim=c(16.5,27.5), ylim=c(0.6,5.4), axes=FALSE, xlab="", ylab="")
sub = which(xyz[,"num"] <= numthresh); apoints(xyz[sub,1], xyz[sub,2], xyz[sub,3], pch=0, scale.lo=scale.lo, scale.hi=scale.hi, col="black", cex=cex-0.25, lwd=2, ljoin=1)
#apolygon(x=c(16.25,16.25,18.75,18.75), y=c(0.5,4.5,4.5,0.5), border=NA, lend=1, density=4.55, col=col2rgba("grey75",0.75), lwd=5)
#apolygon(x=c(27.25,27.25,27.75,27.75), y=c(0.5,4.5,4.5,0.5), border=NA, lend=1, density=4.55, col=col2rgba("grey75",0.75), lwd=5)
mtext(side=2, at=1:4, line=0, las=1, text=c("Q1","Q2","Q3","Q4"))
mtext(side=2, at=2.5, line=1.5, text="Observed")
aaxis(side=1, at=16:30, tick=FALSE)
rect(xl=16.22, xr=27.78, yb=0.45, yt=4.55, lwd=2, border="grey75")

col.bar("top", horizontal=TRUE, flip=TRUE, col.map=col.map, scale.lo=scale.lo, scale.hi=scale.hi, inset=-1.75, seg.num=cbseg, n=cbn)

aplot(uvw[,1], uvw[,2], uvw[,3], pch=15, scale.lo=scale.lo, scale.hi=scale.hi, col.map=col.map, cex=cex, xlim=c(16.5,27.5), ylim=c(0.6,5.4), axes=FALSE, xlab="", ylab="")
mtext(side=2, at=1:4, line=0, las=1, text=c("Q1","Q2","Q3","Q4"))
mtext(side=2, at=2.5, line=1.5, text="Modelled")
aaxis(side=1, at=16:30, tick=FALSE)
rect(xl=16.22, xr=27.78, yb=0.45, yt=4.55, lwd=2, border="grey75")

# finish up
layout(1)
mtext(side=1, line=1.75, text=bquote(paste("apparent magnitude : ", m[r])))
mtext(side=2, line=2.75, text="half light radius", at=2.5)
mtext(side=3, line=1.5, text="median ellipticity")
graphics.off()





