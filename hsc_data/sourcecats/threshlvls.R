#!/usr/bin/Rscript --no-init-file

# definitions
incats = dir("."); incats = grep(".dat", incats, v=T)

# loop
allthresh = {}
for(i in 1:length(incats)){
    
    cat("\b\b\b\b\b     \b\b\b\b\b", i, " ", sep="", collapse="")
    
    dat = read.table(incats[i], stringsAsFactors=FALSE)
    thresh = dat[1,7]
    allthresh = c(allthresh, thresh)
    
}

# dev
cairo_pdf(file="threshlvls.pdf", width=5, height=5)
par("mar"=c(4,3.5,1,1))

# analysis plot
hist(allthresh, breaks=seq(0.06,0.10,by=0.0025), freq=TRUE, axes=FALSE, main="", xlab="", ylab="", col="#f1a340", border=NA, xlim=c(0.06,0.10))
abline(v=seq(0.06,0.10,by=0.0025), col="white", lwd=5)
rug(allthresh, col="#998ec3", lwd=1.25, lend=3)
axis(side=1)
axis(side=2, las=1)
box()
mtext(side=1, text=bquote(paste("threshold / ADU")), line=2.5)
mtext(side=2, text="frequency", line=2)

# finish up
graphics.off()

