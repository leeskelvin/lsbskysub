#!/usr/bin/Rscript --no-init-file

# astro
library(xastro)

# definitions
infiles = dir("../calexp"); infiles = paste0("../calexp/", grep(".dat", infiles, v=T))
area =  # sq deg
bw = 0.5 # magnitude bin width

# plot
aplot(NA, xlim=c(15,29), ylim=c(10^0,10^4), log="y", yformat="p", las=1, type="n", xlab=bquote(m[r]), ylab="galaxies per square degree per magnitude")

# loop
for(i in 1:length(infiles)){
    
    dat = read.table(infiles[i], stringsAsFactors=FALSE)
    colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS")
    
    # binned data
    breaks = c(seq(0,50,by=bw) - (bw/2), 50 + (bw/2))
    h = hist(dat[,"MAG_AUTO"]+27, breaks=breaks, plot=FALSE)
    
    # plot
    points(h$mids, log10(h$counts), pch=i+14, col=c("#f1a340","#998ec3")[i], type="b")
    
}

# trend lines
mr = seq(0,50,by=bw)
logn = 10
lines(x,y*1e2)

