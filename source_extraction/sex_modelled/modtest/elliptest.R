#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
ellips = c(0,0.3,0.5,0.7,0.9,0.95)

# loop
galfitdat = galsimdat = imfitdat = galfitsum = galsimsum = imfitsum = {}
for(i in 1:length(ellips)){
    
    # read and modify
    feed1 = readLines("galfit.feedme")
    feed2 = readLines("galsim.feedme")
    feed3 = readLines("imfit.feedme")
    feed1[grep("# axis ratio", feed1)] = paste(" 9)", 1-ellips[i], "0 # axis ratio")
    feed2[grep("type : QBeta", feed2)+1] = paste("        q :", 1-ellips[i])
    feed3[grep("ell", feed3)] = paste("ell    ",ellips[i])
    cat(feed1, sep="\n", file="galfit.feedme")
    cat(feed2, sep="\n", file="galsim.feedme")
    cat(feed3, sep="\n", file="imfit.feedme")
    
    # run
    system("~/software/galfit/galfit galfit.feedme")
    system("/usr/local/bin/galsim galsim.feedme")
    system("~/software/imfit/makeimage -nrows 201 -ncols 201 imfit.feedme --output imfit.fits")
    
    # read
    dat1 = read.fitsim("galfit.fits")
    dat2 = read.fitsim("galsim.fits")
    dat3 = read.fitsim("imfit.fits")
    dat3 = (dat3/sum(dat3))*sum(dat1)
    write.fits(dat3, file="imfit.fits")
    galfitdat = c(galfitdat, list(dat1[101,101:201]))
    galsimdat = c(galsimdat, list(dat2[101,101:201]))
    imfitdat = c(imfitdat, list(dat3[101,101:201]))
    galfitsum = c(galfitsum, sum(dat1))
    galsimsum = c(galsimsum, sum(dat2))
    imfitsum = c(imfitsum, sum(dat3))
    
}

# dev
pdf(file="elliptest.pdf", height=10, width=8)

# par
palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
layout(matrix(1:length(ellips),ncol=1))
par("mar"=c(0.25,0.25,0.25,0.25))
par("oma"=c(4,4,4,1))

# plot
for(i in 1:length(ellips)){
    labs = 2
    if(i==length(ellips)){labs = c(1,labs)}
    xx = 0:100
    yy = 10^(-0.4*(sersic(r=xx, mag=17, n=1, re=15, e=ellips[i])[,"MU"]-27))
    suppressWarnings(aplot(xx,log10(galfitdat[[i]]/galfitdat[[i]][16]), type="l", col=2, lwd=2, xlab="", ylab="", labels=labs, las=1, xnmin=3, ylim=c(-5,5)))
    suppressWarnings(lines(xx,log10(galsimdat[[i]]/galsimdat[[i]][16]), col=3, lwd=2))
    suppressWarnings(lines(xx,log10(imfitdat[[i]]/imfitdat[[i]][16]), col=7, lwd=2, lty=2, lend=1))
    suppressWarnings(lines(xx,log10(yy/yy[16]), col=1, lwd=2, lty=2, lend=1))
    label("topright", lab=paste("e =", ellips[i]), inset=1, cex=2)
    if(i==1){
        par("xpd"=NA)
        alegend("top", legend=c("Sersic", "GALFIT", "GALSIM", "IMFIT"), type=list(l=list(col=1,lwd=2,lty=2,lend=1), l=list(col=2,lwd=2), l=list(col=3,lwd=2), l=list(col=7,lwd=2,lty=2,lend=1)), ncol=4, cex=1.5, bty="o", inset=0.5, outer=T)
        par("xpd"=FALSE)
    }
}

# finish up
mtext(side=1, text="radius / pixels", outer=TRUE, line=2)
mtext(side=2, text="log normalised flux", outer=TRUE, line=2)
graphics.off()

