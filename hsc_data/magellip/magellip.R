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
dat = dat[dat[,"CLASS_STAR"]<=0.03,] # remove probable stars
dat = dat[sample(x=nrow(dat)),] # randomise for plotting

# loop
bw = 0.5
mags = seq(16.5, 27.5, by=bw)
radlos = radhis = e1s = e2s = e3s = e4s = numeric(length(mags))
for(i in 2:length(mags)){
    samp = which(dat[,"MAG_AUTO"] >= mags[i]-bw/2 & dat[,"MAG_AUTO"] <= mags[i]+bw/2)
    imag = dat[samp,"MAG_AUTO"]
    irad = dat[samp,"FLUX_RADIUS"]
    iellip = dat[samp,"ELLIPTICITY"]
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
    qrad = quantile(irad)
    e1 = iellip[irad >= qrad[1] & irad <= qrad[2]]
    e2 = iellip[irad >= qrad[2] & irad <= qrad[3]]
    e3 = iellip[irad >= qrad[3] & irad <= qrad[4]]
    e4 = iellip[irad >= qrad[4] & irad <= qrad[5]]
    e1s[i] = median(e1)
    e2s[i] = median(e2)
    e3s[i] = median(e3)
    e4s[i] = median(e4)
}

# dev
pdf(file="magellip.pdf", width=8, height=2.75)

# par
par("mar"=c(3,3,3,1))

# plot
col.map = "rainbow"
scale.lo = 0.1
scale.hi = 0.4
xy = expand.grid(x=mags, y=1:4)
xy = cbind(xy, c(e1s,e2s,e3s,e4s))
aplot(xy[,1], xy[,2], xy[,3], pch=15, scale.lo=scale.lo, scale.hi=scale.hi, col.map=col.map, cex=3.5, xlim=c(16.5,27.5), ylim=c(0.5,5.5), axes=FALSE, xlab="", ylab="")
mtext(side=2, at=1.5, line=0, las=1, text=bquote(Q[1]))
mtext(side=2, at=2.5, line=0, las=1, text=bquote(Q[2]))
mtext(side=2, at=3.5, line=0, las=1, text=bquote(Q[3]))
aaxis(side=1, at=16:30, tick=FALSE)
mtext(side=1, line=1.75, text=bquote(paste("apparent magnitude : ", m[r])))
mtext(side=2, line=1.75, text="half light radius", at=2.5)
mtext(side=3, line=1.5, text="median ellipticity")
col.bar("top", horizontal=TRUE, flip=TRUE, col.map=col.map, scale.lo=scale.lo, scale.hi=scale.hi, inset=-1.75, seg.num=499, n=4)
rect(xl=16.2, xr=27.8, yb=0.4, yt=4.6, lwd=2, border="grey75")

# finish up
graphics.off()





