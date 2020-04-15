#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# data
dat = readRDS("../datacollect/skydata.rds")

# definitions
ordera = c(1,5,3,7)
orderb = c(2,6,4,8)
xdats = list(dat$ndet[,ordera], dat$ndet[,orderb])
#ydats = list(1-(dat$nmatch[,ordera]/dat$ndet[,ordera]), 1-(dat$nmatch[,orderb]/dat$ndet[,orderb]))
ydats = list(dat$nmatch[,ordera], dat$nmatch[,orderb])
pdfnames = paste0("ndetnmatch-", c("a","b","a5","b5"), ".pdf")

# par
cex = 1.5
lwd = 1.5
metpch = c(0,3,2,1,4,8,6,5,10,12)
metcol = c(2,2,2,2,3,3,3,3,1,1)
alabs = paste0("number of detected objects", c("","",rep(" (largest 5 matched sources only)",2)))
simsources = paste0("Simulated Flux Subset: ", c("All Sources","Bright Only (No EBL)","All","Bright Only (No EBL)"))

# loop
for(i in 1:length(xdats)){

    # dev
    cairo_pdf(file=pdfnames[i], width=8, height=5.5)

    # par
    layout(rbind(c(1,2),c(3,4)))
    palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
    par("mar"=c(0.25,0.25,0.25,0.25))
    par("oma"=c(4,4.5,7,4))

    # loop
    for(j in 1:ncol(xdats[[i]])){

        # base plot setup
        if(j==1){labs = c(2)}
        if(j==2){labs = c(4)}
        if(j==3){labs = c(1,2)}
        if(j==4){labs = c(1,4)}
        #aplot(NA, xlim=c(2e3,7e4), ylim=c(0.15,0.9), xlab="", ylab="", las=1, side=NA, log="x", labels=labs, tick=FALSE, bty="n")
        aplot(NA, xlim=c(2e3,7e4), ylim=c(6e2,2e4), xlab="", ylab="", las=1, side=NA, log="xy", labels=labs, tick=FALSE, bty="n")
        #abline(h=seq(0,1,by=0.2), col="grey75", lty=2, lend=1)
        #abline(v=c(1,10,100,1000,10000,100000), col="grey75", lty=2, lend=1)
        aaxes(labels=labs, ynmin=1, las=1, xformat="f", mgp=c(2,0.5,0), xdigits=0)
        if(j%in%c(1,2)){mtext(side=3, line=0.25, text=c("low density simulated region","high density simulated region")[j], cex=1)}
        if(j%in%c(1,2)){labtext="exponential sources"}else{labtext="de Vaucouleurs sources"}
        label("topleft", lab=colnames(xdats[[i]])[j], inset=0.5, outline="white")
        label("bottomright", lab=labtext, inset=0.5, outline="white")
        abox()

        # axes labels
        if(j==1 | j==3){
            # at=2000; mtext(side=2, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
            # at=5000; mtext(side=2, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
            # at=20000; mtext(side=2, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
            at=3000; mtext(side=2, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
        }
        if(j==2 | j==4){
            # at=2000; mtext(side=4, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
            # at=5000; mtext(side=4, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
            # at=20000; mtext(side=4, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
            at=3000; mtext(side=4, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
        }
        if(j==3 | j==4){
            # at=2000; mtext(side=1, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
            # at=5000; mtext(side=1, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
            # at=20000; mtext(side=1, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
            # at=50000; mtext(side=1, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
            at=3000; mtext(side=1, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
            at=30000; mtext(side=1, text=at, at=at, las=1, cex=0.83, col="black", line=0.5)
        }

        # % lines
        xx = c(1,100000)
        lines(xx, xx*1, lty=2, col="grey75")
        lines(xx, xx*0.5, lty=2, col="grey75")
        lines(xx, xx*0.2, lty=2, col="grey75")
        lines(xx, xx*0.1, lty=2, col="grey75")
        if(j==1){
            xat=1e4; label(x=xat, y=xat*1.0, lab="100%", col="grey75", outline="white", outline.lwd=5000, srt=31)
            xat=1.55e4; label(x=xat, y=xat*0.5, lab="50%", col="grey75", outline="white", outline.lwd=5000, srt=31)
            xat=2.65e4; label(x=xat, y=xat*0.2, lab="20%", col="grey75", outline="white", outline.lwd=5000, srt=31)
            xat=4e4; label(x=xat, y=xat*0.1, lab="10%", col="grey75", outline="white", outline.lwd=5000, srt=31)
        }

        # points
        apoints(xdats[[i]][,j], ydats[[i]][,j], pch=metpch, lwd=lwd, cex=cex, lend=1, col=metcol)

    }

    # labels & legend
    par("xpd"=NA)
    mtext(side=1, line=2, text=alabs[i], outer=T)
    mtext(side=2, line=2.5, text=bquote(paste("number of matched objects")), outer=T)
    #mtext(side=3, line=1.5, text=simsources[i], outer=T)
    alegend("top", legend=names(dat$files), ncol=4, byrow=T, inset=0.5, outer=TRUE, seg.len=0.8, seg.gap=0.4,  type=setNames(apply(cbind(pch=metpch,lwd=lwd,col=metcol,cex=cex), 1, as.list), rep("p",length(dat$files))), bty="o", cex=0.9, box.pad=0.25, line.spacing=1.25)

    # finish up
    graphics.off()

}

# # merge into 1 PDF
# system(paste("/usr/bin/gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=ndetnmatch.pdf ndetnmatch-a.pdf ndetnmatch-b.pdf"))

