#!/usr/bin/Rscript --no-init-file

# definitions
indir = "../sourcecats/"
imstats = read.csv("../sourcecats/imstats.csv", stringsAsFactors=FALSE)
incats = paste0(unlist(strsplit(imstats[,"FILE"],".fits.fz")),".dat")
#areas = imstats[,"AREA"]

# loop
numden = {}
newareas = {}
for(i in 1:length(incats)){
    
    cat("\b\b\b\b\b     \b\b\b\b\b", i, " ", sep="", collapse="")
    
    dat = read.table(paste0(indir,"/",incats[i]), stringsAsFactors=FALSE)
    fitsim = paste0(strsplit(incats[i], ".dat")[[1]], ".fits.fz")
    myrow = which(imstats[,"FILE"] == fitsim)
    area = imstats[myrow,"AREA"]
    numden = c(numden, nrow(dat)/area)
    newareas = c(newareas, area)
    
}

# dev
cairo_pdf(file="patchden.pdf", width=5, height=5)
par("mar"=c(4,3.5,1,1))

# analysis plot
xlims = c(150000,350000,12500)
hist(numden, breaks=seq(xlims[1],xlims[2],by=xlims[3]), freq=TRUE, axes=FALSE, main="", xlab="", ylab="", col="#f1a340", border=NA, xlim=c(xlims[1],xlims[2]))
abline(v=seq(xlims[1],xlims[2],by=xlims[3]), col="white", lwd=5)
rug(numden, col="#998ec3", lwd=1.25, lend=3)
axis(side=1)
axis(side=2, las=1)
box()
mtext(side=1, text=bquote(paste(N["obj"], " / sq. degree")), line=2.5)
mtext(side=2, text="frequency", line=2)

# finish up
graphics.off()

# catalogue
oo = order(numden)
write.csv(data.frame(CAT=incats[oo], NUMDEN=numden[oo], AREA=newareas[oo]), file="patchden.csv", row.names=FALSE, quote=FALSE)

# quantiles
qq = quantile(numden, c(0.05,0.95))
cat("\n")
print(paste0("Quantile 1: ", incats[which.min(abs(qq[1] - numden))]))
print(paste0("Quantile 2: ", incats[which.min(abs(qq[2] - numden))]))

