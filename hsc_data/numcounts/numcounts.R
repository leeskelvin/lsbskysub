#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)

# definitions
infiles = dir("../calexp"); infiles = paste0("../calexp/", grep(".dat", infiles, v=T))
imstats = read.csv("../sourcecats/imstats.csv", stringsAsFactors=FALSE)
bw = 0.5 # magnitude bin width

# dev
cairo_pdf(file="numcounts.pdf", width=8, height=4)

# par
layout(cbind(1,2))
par("mar"=c(0.5,0.5,0.5,0.5))
par("oma"=c(2.5,3.5,1,1.5))

# loop
for(i in 1:length(infiles)){
    
    # plot
    aplot(NA, xlim=c(14.5,30.5), ylim=c(4*10^1,2*10^7), log="y", yformat="p", las=1, type="n", xlab=bquote(paste("apparent magnitude : ", m[r])), ylab=bquote(paste(N[obj], " ", deg^{-2}, " ", mag^{-1})), xnmin=1, axes=FALSE)
    mtext(side=3, line=0.25, text=c("low density region : 8283-38", "high-density region : 9592-20")[i])
    
    # raw data
    dat = read.table(infiles[i], stringsAsFactors=FALSE)
    colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS")
    mags = dat[,"MAG_AUTO"]; if(any(mags == 99)){mags[mags==99]=NA}; mags = mags + 27
    area = imstats[grep(strsplit(basename(infiles[i]), ".dat")[[1]][1], imstats[,"FILE"]),"AREA"]
    
    # binned data
    breaks = c(seq(0,50,by=bw) - (bw/2), 50 + (bw/2))
    h = hist(mags, breaks=breaks, plot=FALSE)
    binmag = h$mids
    bindat = (h$counts / area) / bw
    bindatlog = log10(bindat); if(any(bindatlog==-Inf)){bindatlog[bindatlog==-Inf] = 0}
    
    # power law line fit
    magbright = 22
    magfaint = 25
    fn = function(x, a){return(a + 0.4*x)}
    good = which(binmag >= magbright & binmag <= magfaint)
    fitdat = fit(data=bindatlog[good], par=list(a=1), fn=fn, arg=list(x=binmag[good]))
    binexplog = fn(x=binmag, a=fitdat$par$a)
    binexp = 10^binexplog
    binfaint = binexp - bindat
    binfaintlog = suppressWarnings(log10(binfaint))
    
    # plot
    objlim = (1/area)/bw
    maglower = binmag[which(binexp >= objlim)[1]-1]
    magupper = 30
    bars(x=binmag[binmag>=maglower & binmag<=magbright], y=binexp[binmag>=maglower & binmag<=magbright], width=bw, col="grey50", joined=TRUE)
    bars(x=binmag[binmag>=magfaint & binmag<=magupper], y=binfaint[binmag>=magfaint & binmag<=magupper], width=bw, col="grey75", joined=TRUE)
    bars(x=binmag, y=bindat, width=bw, col=NA, border=c("#5e3c99","#e66101")[i], joined=TRUE, lwd=2, ljoin=1)
    bars(x=binmag[binmag>magbright], y=bindat[binmag>magbright], col=c("#5e3c99","#e66101")[i], density=25, angle=-45, joined=TRUE)
    abline(a=fitdat$par$a, b=0.4, col=c("#b2abd2","#fdb863")[i], lwd=1.5)
    abline(v=c(magbright,magfaint), lty=2, lend=3, lwd=1.5)
    abline(h=objlim, lty=3, lend=3)
    
    # legend
    alegend("topleft", legend=c("detected", "expected", "bright substitutes", "faint missing", "detected adopted"), type=list(l=list(col=c("#5e3c99","#e66101")[i],lwd=2,lend=1), l=list(col=c("#b2abd2","#fdb863")[i],lwd=1.5,lend=1), f=list(col="grey50",border=NA), f=list(col="grey75",border=NA), f=list(col=c("#5e3c99","#e66101")[i],density=25,angle=-45,border=NA)), cex=0.75)
    
    # finish up
    aaxes(las=1, yformat="p", labels=list(c(1,2),c(1,4))[[i]], xnmin=9, mgp=c(2,0.25,0))
    mtext(side=c(2,5)[i], line=2, text=bquote(paste(N[obj], " ", deg^{-2}, " ", mag^{-1})))
    
    # sim-relevant data
    simmag = binmag
    simden = rep(0, length(simmag))
    simden[simmag >= maglower & simmag <= magbright] = binexp[simmag >= maglower & simmag <= magbright]
    simden[simmag >= magfaint & simmag <= magupper] = binfaint[simmag >= magfaint & simmag <= magupper]
    simcat = cbind(MAG=simmag, DEN=simden, NUM=simden*bw*area)
    write.csv(simcat, row.names=FALSE, quote=FALSE, file=paste0(strsplit(basename(infiles[i]), ".image.dat")[[1]][1], ".extra.csv"))
    
    # numbers
    ncex = 0.75
    nreal = sum(bindat[binmag > magbright] * bw * area)
    nextra.bright = sum(ceiling(simden[simmag<=magbright] * bw * area))
    nextra.faint = sum(ceiling(binfaint[binmag>=magfaint & binmag<=magupper] * bw * area))
    text(x=magbright, y=objlim, lab=nextra.bright, col="white", adj=c(1.25,-0.5), cex=ncex)
    text(x=mean(c(magbright,magfaint)), y=objlim, lab=nreal, col="black", adj=c(0.5,-0.5), cex=ncex)
    text(x=magfaint, y=objlim, lab=nextra.faint, col="white", adj=c(-0.25,-0.5), cex=ncex)
    
}

# finish up
layout(1)
mtext(side=1, line=1.75, text=bquote(paste("apparent magnitude : ", m[r])))
graphics.off()

