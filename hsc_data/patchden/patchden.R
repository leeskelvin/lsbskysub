#!/usr/bin/Rscript --no-init-file

# definitions
indir = "../sourcecats/"
inlist = dir(indir)
incats = grep(".dat", inlist, value=TRUE)

# loop
numden = {}
for(i in 1:length(incats)){
    
    cat("\b\b\b\b\b     \b\b\b\b\b", i, " ", sep="", collapse="")
    
    dat = read.table(paste0(indir,"/",incats[i]), stringsAsFactors=FALSE)
    numden = c(numden, nrow(dat))
    
}

# dev
cairo_pdf(file="patchden.pdf", width=5, height=5)
par("mar"=c(4,3.5,1,1))

# analysis plot
hist(numden, breaks=seq(4000,14000,by=500), freq=TRUE, axes=FALSE, main="", xlab="", ylab="", col="#f1a340", border=NA, xlim=c(5000,13000))
abline(v=seq(4000,14000,by=500), col="white", lwd=5)
rug(numden, col="#998ec3", lwd=1.25, lend=3)
axis(side=1)
axis(side=2, las=1)
box()
mtext(side=1, text=bquote(paste(N["obj"], " / patch")), line=2.5)
mtext(side=2, text="frequency", line=2)

# finish up
graphics.off()

# catalogue
write.csv(data.frame(CAT=incats, NUMDEN=numden), file="patchden.csv", row.names=FALSE, quote=FALSE)

