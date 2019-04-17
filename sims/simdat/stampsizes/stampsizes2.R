#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
v3dat1 = read.table("v3/b/calexp-HSC-R-8283-38.cat-input-n1.dat")
v3dat2 = read.table("v3/b/calexp-HSC-R-8283-38.cat-input-n4.dat")
v3dat3 = read.table("v3/b/calexp-HSC-R-9592-20.cat-input-n1.dat")
v3dat4 = read.table("v3/b/calexp-HSC-R-9592-20.cat-input-n4.dat")
v3dat = rbind(v3dat1,v3dat2,v3dat3,v3dat4)
v5dat1 = read.table("v5/calexp-HSC-R-8283-38.cat-input-n1-b.dat")
v5dat2 = read.table("v5/calexp-HSC-R-8283-38.cat-input-n4-b.dat")
v5dat3 = read.table("v5/calexp-HSC-R-9592-20.cat-input-n1-b.dat")
v5dat4 = read.table("v5/calexp-HSC-R-9592-20.cat-input-n4-b.dat")
v5dat = rbind(v5dat1,v5dat2,v5dat3,v5dat4)
colnames(v3dat) = colnames(v5dat) = c("x","y","flux","half_light_radius","q","theta","n","stamp_size")
v3dat[,"stamp_size"] = v3dat[,"stamp_size"]-10 # to correct for 10-pixel padding in the v3 dataset
col = rep(2,nrow(v3dat))
col[v3dat[,"n"]==4] = 3
xlim = ylim = range(c(v3dat[,"stamp_size"],v5dat[,"stamp_size"]))

# dev
pdf(file="stampsizes2.pdf", width=5, height=5)

# par
par("mar"=c(3.5,3.5,2,2))
palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))

# plot
aplot(v3dat[,"stamp_size"], v5dat[,"stamp_size"], pch=".", xlab="v3 stamp size / pixels", ylab="v5 stamp size / pixels\n", mgp=c(1.5,0.25,0), las=1, xformat="p", yformat="p", xlim=xlim, ylim=ylim, col=col2rgba(col,0.01), cex=2, log="xy")

par("xpd"=TRUE)
scales = c(seq(0.1,1.2,by=0.1),2)
for(i in 1:length(scales)){
    x = 10^seq(par("usr")[1], par("usr")[2], len=100)
    y = scales[i] * x
    bad = which(y < 10^par("usr")[3])
    if(length(bad) > 0){
        x = x[-bad]
        y = y[-bad]
    }
    lty = ifelse(scales[i]==1,1,2)
    lwd = ifelse(scales[i]==1,2.5,1)
    lines(x,y,lty=lty,lwd=lwd,lend=1)
    topinset = 0 # 1*(scales[i]-1)*floor(scales[i]-0.01)
    topsrt = 0 # 45*floor(scales[i]-0.01)
    #par("xpd"=TRUE)
    text(x=10^(par("usr")[2]-topinset+0.075), y=scales[i]*(10^par("usr")[2]), lab=paste0(scales[i]*100,"%"), cex=0.5, srt=topsrt)
    #par("xpd"=FALSE)
}
par("xpd"=FALSE)

alegend("topleft", legend=c("n = 1 (exponential)", "n = 4 (de Vaucouleurs)", "1:1 line", "10% increments"), type=list(p=list(pch=".",col=2,cex=10),p=list(pch=".",col=3,cex=10),l=list(lwd=2.5,lend=1),l=list(lty=2,lend=1)))

# finish up
graphics.off()

