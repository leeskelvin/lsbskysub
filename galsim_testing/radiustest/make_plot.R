#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# data
dats = simplify2array(list(
    read.csv("sextractor-n0.5.csv")
    ,read.csv("sextractor-n1.0.csv")
    ,read.csv("sextractor-n2.0.csv")
    ,read.csv("sextractor-n4.0.csv")
    ,read.csv("sextractor-n6.0.csv")
))
maincols = c("R","a","b")
maincolsname = c("Circularised Radius", "Semi-Major Radius", "Semi-Minor Radius")
mainrows = c("","FLUX_RADIUS","A_IMAGE","B_IMAGE","SPHEROID_REFF_IMAGE")
ns = {}; for(l in 1:ncol(dats)){ns = c(ns, as.numeric(dats["N",][[l]][1]))}

# dev
pdf(file="radiustest.pdf", width=8, height=9)

# par
par("mar"=c(0.5,4.0,0.5,0.5))
par("oma"=c(4,0,2,1))
layout(cbind(c(1,0,2:5),c(1,0,2:5),c(1,0,6:9),c(0,0,6:9),c(0,0,10:13),c(0,0,10:13)), heights=c(5,1.25,3,3,3,3))
palette(c("#000000", "#5e3c99", "#2c7fb8", "#7fcdbb", "#fdb863", "#e66101"))
xlim = c(0,0.95)
cex = 0.75

# loop
for(i in 1:length(maincols)){
    
    if(i==1){jlo=1}else{jlo=2}
    
    for(j in jlo:length(mainrows)){
        
        # setup
        if(j==1){
            ylim = log10(c(0.4,7))
            ydat = {}; for(l in 1:ncol(dats)){ydat = c(ydat, list(log10(dats["SPHEROID_SERSICN",][[l]])))}
            ylab = "fitted Sérsic index"
            log = ""
            yunlog = T
        }else{
            ylim = c(0.3,11)
            ydat1 = dats[which(rownames(dats)==toupper(maincols[i])),]
            ydat2 = dats[which(rownames(dats)==mainrows[j]),]
            ylab = gsub("SPHEROID_REFF_IMAGE","SPHEROID_REFF",paste(mainrows[j], " / ", maincols[i]))
            ydat = {}; for(l in 1:ncol(dats)){ydat = c(ydat, list(ydat2[[l]] / ydat1[[l]]))}
            log = "y"
            yunlog = F
        }
        ellip = dats["ELLIP",]
        
        # plot
        labs = 2; if(j==length(mainrows)){labs = c(1,2)}; if(j==1 & i==1){labs = 1}
        aplot(NA, xlim=xlim, ylim=ylim, xlab="", ylab=ylab, labels=labs, las=1, cex.lab=0.9, log=log, xnmin=1, yunlog=yunlog)
        if(j==2){mtext(side=3, text=maincolsname[i], line=0.25, cex=0.85)}
        if(i==1 & j==1){mtext(side=1, text="input ellipticity", line=1.5, cex=0.75, at=0.45)}
        if(i==1 & j==1){mtext(side=2, text=c(0.5,1,2,4,6), las=1, line=0.25, cex=0.65, at=log10(c(0.5,1,2,4,6)))}
        if(i==1 & j==1){mtext(side=4, text=c(0.5,1,2,4,6), las=1, line=0.25, cex=0.65, at=log10(c(0.5,1,2,4,6)))}
        if(i==1 & j==1){for(l in 1:ncol(dats)){abline(h=log10(ns[l]),col=col2hex(l+1,alpha=0.25),lwd=5)}}
        if(i==1 & j==2){label("topleft", label="R = 15 pixels", inset=0.5)}
        if(i==1 & j==1){
            par("xpd"=NA)
            ybase = par("usr")[4] + 0.075
            #abline(h=ybase, col="grey75", lwd=0.5)
            xyusr = c(grconvertX(c(0,1),from='device'), grconvertY(c(0,1),from='device'))
            for(ell in c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9)){
                xy = ellipse(a=sqrt((0.025^2)/(1-ell)), e=ell, x0=ell, y0=0, pa=0)
                xy[,"y"] = (xy[,"y"] * (diff(xyusr)[3] / diff(xyusr)[1])) + ybase
                apolygon(xy, border="black", col=grey(ell*0.85,alpha=0.5), lwd=0.5)
            }
            par("xpd"=FALSE)
        }
        
        # points
        for(k in 1:ncol(dats)){
            points(x=ellip[[k]], y=ydat[[k]], pch=16, col=k+1, cex=cex)
        }
        
        # additional plotting
        if(j!=1){abline(h=1, col=1, lty=2, lend=1, lwd=1.5)}
        
    }
    
}

# finish up
mtext(side=1, text="input ellipticity", outer=T, line=1.75, at=0.53)
par("xpd"=NA)
alegend("topright", legend=paste0("n=",ns), type=setNames(apply(cbind(pch=rep(16,length(ns)),cex=rep(2,length(ns)),col=1:ncol(dats)+1),1,as.list), rep("p",length(ns))), bty="o", seg.len=0.25, seg.gap=0.25, ncol=length(ns), outer=T, inset=2, cex=1.5)
xoff = 1.5
label("topleft", lab=bquote(paste("axis ratio : ")), outer=TRUE, inset=c(xoff+23,5.01), cex=1.5)
label("topleft", lab=bquote(paste("ellipticity : ")), outer=TRUE, inset=c(xoff+23,6.25), cex=1.5)
label("topleft", lab=bquote(paste("circularised radius : ")), outer=TRUE, inset=c(xoff+23,7.45), cex=1.5)
label("topleft", lab=bquote(paste("semi-major radius : ")), outer=TRUE, inset=c(xoff+23,8.6), cex=1.5)
label("topleft", lab=bquote(paste("semi-minor radius : ")), outer=TRUE, inset=c(xoff+23,9.85), cex=1.5)
xoff2 = 7.75
label("topleft", lab=bquote(paste("q = b / a")), outer=TRUE, inset=c(xoff+xoff2+23,5), cex=1.5)
label("topleft", lab=bquote(paste("e = 1 - q")), outer=TRUE, inset=c(xoff+xoff2+23,6.25), cex=1.5)
label("topleft", lab=bquote(paste("R = ",sqrt("ab"))), outer=TRUE, inset=c(xoff+xoff2+23,7.25), cex=1.5)
label("topleft", lab=bquote(paste("a = R /",sqrt(q))), outer=TRUE, inset=c(xoff+xoff2+23,8.40), cex=1.5)
label("topleft", lab=bquote(paste("b = R ",sqrt(q))), outer=TRUE, inset=c(xoff+xoff2+23,9.65), cex=1.5)
par("xpd"=FALSE)
graphics.off()

