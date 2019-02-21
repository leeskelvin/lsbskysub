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
par("oma"=c(2.5,3.5,1,3.5))

# loop
for(i in 1:length(infiles)){
    
    # plot
    aplot(NA, xlim=c(14.5,30.5), ylim=c(10^0,10^7), log="y", yformat="p", las=1, type="n", xlab=bquote(paste("apparent magnitude : ", m[r])), ylab=bquote(paste(N[obj], " ", deg^{-2}, " ", mag^{-1})), xnmin=1, axes=FALSE)
    mtext(side=3, line=0.25, text=c("low density region : 8283-38", "high-density region : 9592-20")[i])
    
    # raw data
    dat = read.table(infiles[i], stringsAsFactors=FALSE)
    colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS")
    mags = dat[,"MAG_AUTO"]; if(any(mags == 99)){mags[mags==99]=NA}; mags = mags + 27
    area = imstats[grep(strsplit(basename(infiles[i]), ".dat")[[1]][1], imstats),"AREA"]
    
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
    magupper = 30
    lines(binmag[binmag>=magfaint & binmag<=magupper], binfaint[binmag>=magfaint & binmag<=magupper], col="grey90", type="h", lwd=7.5, lend=3)
    lines(binmag-bw/2, bindat, col=c("#5e3c99","#e66101")[i], type="s", lwd=2, lend=3)
    lines(binmag+bw/2, bindat, col=c("#5e3c99","#e66101")[i], type="S", lwd=2, lend=3)
    abline(a=fitdat$par$a, b=0.4, col=c("#b2abd2","#fdb863")[i], lwd=1.5)
    abline(v=c(magbright,magfaint), lty=2, lend=3, lwd=1.5)
    
    # legend
    cex = 0.5
    inset = c(0.025,0.025)
    legend("topleft", legend=c("detected","","faint missing"), lty=c(1,1,NA), lwd=c(2,1.5,NA), col=c("#5e3c99","#b2abd2",NA), fill=c(NA,NA,"grey90"), border=NA, bty="n", inset=inset, cex=cex, merge=T)
    legend("topleft", legend=bquote(paste("log"[10], N["obj"]," = ", .(formatC(fitdat$par$a,format="f",digits=2)), " + 0.4", m[r], sep="")), lwd=1.5, col=c("#b2abd2","#fdb863")[i], bty="n", inset=inset+c(0,0.031), cex=cex)
    
    # finish up
    aaxes(las=1, yformat="p", labels=list(c(1,2),c(1,4))[[i]], xnmin=4)
    mtext(side=c(2,4)[i], line=2.5, text=bquote(paste(N[obj], " ", deg^{-2}, " ", mag^{-1})))
    
}

## trend lines
#mr = seq(0,50,by=bw)
#logn = 10
#lines(x,y*1e2)

# finish up
layout(1)
mtext(side=1, line=2, text=bquote(paste("apparent magnitude : ", m[r])))
graphics.off()

