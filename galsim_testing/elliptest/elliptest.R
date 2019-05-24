#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
ellips = c(0,0.3,0.5,0.7,0.9,0.95)

# loop
galsimdat = galfitdat = imfitdat = galsimrad = galfitrad = imfitrad = {}
for(i in 1:length(ellips)){
    
    # read and modify
    feed1 = readLines("galsim.config")
    feed2 = readLines("galfit.config")
    feed3 = readLines("imfit.config")
    feed1[grep("type : QBeta", feed1)+1] = paste("        q :", 1-ellips[i])
    feed2[grep("# axis ratio", feed2)] = paste(" 9)", 1-ellips[i], "0 # axis ratio")
    feed3[grep("ell", feed3)] = paste("ell    ",ellips[i])
    
    feed1[grep("half_light_radius", feed1)] = paste("    half_light_radius :", sqrt(15*15*(1-ellips[i])))
    
    # write config files back out
    cat(feed1, sep="\n", file="galsim.config")
    cat(feed2, sep="\n", file="galfit.config")
    cat(feed3, sep="\n", file="imfit.config")
    
    # run
    system("/usr/local/bin/galsim galsim.config")
    system("~/software/galfit/galfit galfit.config")
    system("~/software/imfit/makeimage -nrows 201 -ncols 201 imfit.config --output imfit.fits")
    
    # read
    dat1 = read.fitsim("galsim.fits")
    dat2 = read.fitsim("galfit.fits")
    dat3 = read.fitsim("imfit.fits")
    dat2 = (dat2/sum(dat2))*sum(dat1)
    dat3 = (dat3/sum(dat3))*sum(dat1)
    
    # add to lists
    galsimdat = c(galsimdat, list(dat1))
    galfitdat = c(galfitdat, list(dat2))
    imfitdat = c(imfitdat, list(dat3))
    galsimrad = c(galsimrad, list(dat1[101:201,101]))
    galfitrad = c(galfitrad, list(dat2[101:201,101]))
    imfitrad = c(imfitrad, list(dat3[101:201,101]))
    
    # clean up
    unlink(c("galsim.fits","galfit.fits","imfit.fits"))
    
}

# dev
#png(file="elliptest.png", height=8.5, width=8, units="in", res=300)
pdf(file="elliptest.pdf", height=8.25, width=8)

# par
palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
layout(matrix(1:(length(ellips)*4),ncol=4,byrow=TRUE), widths=c(3,1,1,1))
par("mar"=c(0.25,0.25,0.25,0.25))
par("oma"=c(4,4,1,1))

# plot
for(i in 1:length(ellips)){
    
    # setup
    scale.lo = -1e-5
    scale.hi = 15
    lwd = 2.5
    galsimradmax = which(galsimrad[[i]] < 0)[1]; if(is.na(galsimradmax)){galsimradmax = length(galsimrad[[i]])}
    galfitradmax = which(galfitrad[[i]] < 0)[1]; if(is.na(galfitradmax)){galfitradmax = length(galfitrad[[i]])}
    imfitradmax = which(imfitrad[[i]] < 0)[1]; if(is.na(imfitradmax)){imfitradmax = length(imfitrad[[i]])}
    lvls = 10^(-5:+1)
    cols = grey((length(lvls)+1):1/(length(lvls)+1))[-1]
    lwds = 2
    
    # 1D profile
    labs = 2
    if(i==length(ellips)){labs = c(1,labs)}
    xx = 0:100
    aplot(NA, xlim=range(xx), ylim=c(-5,3), xlab="", ylab="", labels=labs, xnmin=3, las=1, ynmin=1)
    suppressWarnings(lines(xx[1:galsimradmax],log10(galsimrad[[i]][1:galsimradmax]/galsimrad[[i]][16]), col=1, lwd=lwd, lty=1, lend=1))
    suppressWarnings(lines(xx[1:galfitradmax],log10(galfitrad[[i]][1:galfitradmax]/galfitrad[[i]][16]), col=4, lwd=lwd, lty=1, lend=1))
    suppressWarnings(lines(xx[1:imfitradmax],log10(imfitrad[[i]][1:imfitradmax]/imfitrad[[i]][16]), col=3, lwd=lwd, lty=2, lend=1))
    label("top", lab=paste("axis ratio : q =", 1-ellips[i]), inset=0.5, cex=1.5)
    if(i==length(ellips)){
        mtext(side=1, text="semi major radius / pixels", line=2)
    }
    if(i==1){
        alegend("topright", legend=c("GALSIM", "GALFIT", "IMFIT"), type=list(l=list(col=1,lwd=lwd,lty=1,lend=1), l=list(col=4,lwd=lwd,lty=1,lend=1), l=list(col=3,lwd=lwd,lty=2,lend=1)), ncol=1, cex=1, bty="o", inset=0.5, outer=F)
    }
    
    # 2D maps
#    aimage(galsimdat[[i]], col.map="sls", scale.lo=scale.lo, scale.hi=scale.hi, axes=FALSE, scale.type="log")
#    if(i==1){mtext(side=3, line=0.5, text="GALSIM")}
#    aimage(galfitdat[[i]], col.map="sls", scale.lo=scale.lo, scale.hi=scale.hi, axes=FALSE, scale.type="log")
#    if(i==1){mtext(side=3, line=0.5, text="GALFIT")}
#    aimage(imfitdat[[i]], col.map="sls", scale.lo=scale.lo, scale.hi=scale.hi, axes=FALSE, scale.type="log")
#    if(i==1){mtext(side=3, line=0.5, text="IMFIT")}
    
    # 2D maps
    contour(x=1:201-101, y=1:201-101, z=galsimdat[[i]], levels=lvls, drawlabels=FALSE, axes=FALSE, xaxs="i", yaxs="i", col=cols, lwd=lwds, asp=1, lend=1, ljoin=1)
    aaxes(xnmin=1, ynmin=1, labels=FALSE); abox()
    if(i==length(ellips)){mtext(side=1, line=1, text="GALSIM")}
    contour(x=1:201-101, y=1:201-101, z=galfitdat[[i]], levels=lvls, drawlabels=FALSE, axes=FALSE, xaxs="i", yaxs="i", col=cols, lwd=lwds, asp=1, lend=1, ljoin=1)
    aaxes(xnmin=1, ynmin=1, labels=FALSE); abox()
    if(i==length(ellips)){mtext(side=1, line=1, text="GALFIT")}
    contour(x=1:201-101, y=1:201-101, z=imfitdat[[i]], levels=lvls, drawlabels=FALSE, axes=FALSE, xaxs="i", yaxs="i", col=cols, lwd=lwds, asp=1, lend=1, ljoin=1)
    aaxes(xnmin=1, ynmin=1, labels=FALSE); abox()
    if(i==length(ellips)){mtext(side=1, line=1, text="IMFIT")}
    
}

# finish up
mtext(side=2, text="log normalised flux", outer=TRUE, line=2)
graphics.off()

