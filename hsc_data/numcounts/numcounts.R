#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)

# definitions
infiles = dir("../calexp"); infiles = paste0("../calexp/", grep(".dat", infiles, v=T))
imstats = read.csv("../sourcecats/imstats.csv", stringsAsFactors=FALSE)
bw = 0.5 # magnitude bin width

# dev


# par
layout(cbind(1,2))
par("mar"=c(4,4,1,1))

# loop
for(i in 1:length(infiles)){
    
    # plot
    aplot(NA, xlim=c(15,29), ylim=c(10^0,10^6), log="y", yformat="p", las=1, type="n", xlab=bquote(paste("apparent magnitude : ", m[r])), ylab=bquote(paste(N[obj], " ", deg^{-2}, " ", mag^{-1})), xnmin=1)
    
    # raw data
    dat = read.table(infiles[i], stringsAsFactors=FALSE)
    colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS")
    mags = dat[,"MAG_AUTO"]; if(any(mags == 99)){mags[mags==99]=NA}; mags = mags + 27
    area = imstats[grep(strsplit(basename(infiles[i]), ".dat")[[1]][1], imstats),"AREA"]
    
    # binned data
    breaks = c(seq(0,50,by=bw) - (bw/2), 50 + (bw/2))
    h = hist(mags, breaks=breaks, plot=FALSE)
    #h$counts = log10(h$counts/area); h$counts[h$counts < 0] = 0
    
    # plot
    lines(h$mids, h$counts/area, col=c("#f1a340","#998ec3")[i], type="h", lwd=3, lend=3)
    #points(h$mids, h$counts/area, pch=i+14, col=c("#f1a340","#998ec3")[i], type="b")
    
}

# trend lines
mr = seq(0,50,by=bw)
logn = 10
lines(x,y*1e2)

