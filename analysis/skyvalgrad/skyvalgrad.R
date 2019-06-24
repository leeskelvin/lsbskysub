#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# data
dat = readRDS("../datacollect/skydata.rds")

# definitions
fn = function(flux){-2.5*log10(flux/(0.168^2))+27}
ordera = c(1,5,3,7)
orderb = c(2,6,4,8)
xdats = list(dat$skyspr[,ordera], dat$skyspr[,orderb])
ydats = list(dat$skymean[,ordera], dat$skymean[,orderb])
pdfnames = paste0("skyvalgrad-", c("a","b","a5","b5"), ".pdf")

# par
cex = 1.5
lwd = 1.5
metpch = c(0,3,2,1,4,8,6,5,10,12)
metcol = c(2,2,2,2,3,3,3,3,1,1)
alabs = paste0("maximum subtracted sky gradient (superpixel) / ADU", c("","",rep(" (largest 5 matched sources only)",2)))
simsources = paste0("Simulating ", c("All Sources","Bright Only (No EBL)","All","Bright Only (No EBL)"))

# loop
for(i in 1:length(xdats)){
    
    # dev
    cairo_pdf(file=pdfnames[i], width=8, height=6)
    
    # par
    layout(rbind(c(1,2),c(3,4)))
    palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
    par("mar"=c(0.25,0.25,0.25,0.25))
    par("oma"=c(4,4.5,7.5,4))
    
    # loop
    for(j in 1:ncol(xdats[[i]])){
        
        # base plot setup
        if(j==1){labs = c(2)}
        if(j==2){labs = c()}
        if(j==3){labs = c(1,2)}
        if(j==4){labs = c(1)}
        aplot(NA, xlim=c(0.00004,0.002), ylim=c(-0.0010,0.01425), xlab="", ylab="", las=1, side=NA, log="x", labels=labs, tick=FALSE, bty="n")
        abline(h=c(-0.005,0,0.005,0.01,0.015), col="grey75", lty=2, lend=1)
        abline(v=c(0.00001,0.0001,0.001,0.01,0.1,1), col="grey75", lty=2, lend=1)
        aaxes(side=1:3, labels=labs, ynmin=4, las=1, xformat="p", mgp=c(2,0.5,0))
        aaxis(side=4, fn=fn, at=c(28:38), labels=FALSE, nmin=1)
        if(j%in%c(2,4)){aaxis(side=4, fn=fn, at=c(28,29,30,31), tick=FALSE, las=1, mgp=c(2,0.5,0))}
        if(j%in%c(2,4)){mtext(side=4, at=0.00005, line=0.5, las=1, text="∞", cex=1)}
        if(j%in%c(1,2)){mtext(side=3, line=0.25, text=c("low density","high density")[j], cex=1)}
        if(j%in%c(1,2)){labtext="exponential"}else{labtext="de Vaucouleurs"}
        label("topleft", lab=labtext, inset=0.5, outline="white")
        abox()
        #if(j==1){alegend("topleft", legend=c("SExtractor","Gnuastro","DM stack"), ncol=1, inset=0.5, seg.len=0.8, seg.gap=0.4, type=setNames(apply(cbind(pch=0,lwd=lwd,col=c(2,3,1),cex=cex,border=NA), 1, as.list), rep("f",3)), bty="o", cex=0.9, box.pad=0.1)}
        
        # points
        apoints(xdats[[i]][,j], ydats[[i]][,j], pch=metpch, lwd=lwd, cex=cex, lend=1, col=metcol)
        
    }
    
    # labels & legend
    par("xpd"=NA)
    mtext(side=1, line=2, text=alabs[i], outer=T)
    mtext(side=2, line=2.5, text=bquote(paste("mean subtracted sky level / ADU ", pixel^{-2})), outer=T)
    mtext(side=3, line=1, text=simsources[i], outer=T)
    mtext(side=4, line=2, text=bquote(paste("mean subtracted sky level / mag ", arcsec^{-2})), outer=T)
    alegend("top", legend=names(dat$files), ncol=4, byrow=T, inset=0.5, outer=TRUE, seg.len=0.8, seg.gap=0.4,  type=setNames(apply(cbind(pch=metpch,lwd=lwd,col=metcol,cex=cex), 1, as.list), rep("p",length(dat$files))), bty="o", cex=0.9, box.pad=0.25, line.spacing=1.25)
    
    # finish up
    graphics.off()
    
#    # quick analysis PNG
#    system(paste0("/usr/bin/convert -density 300 ", pdfnames[i], " -quality 90 temp", i, ".png"))
    
}

## PNG update
#system("mv skyvalgrad.png skyvalgrad-old.png")
#system("/usr/bin/montage temp1.png temp2.png temp3.png temp4.png -geometry 800x600 skyvalgrad.png")
#unlink(c("temp1.png","temp2.png","temp3.png","temp4.png"))

# merge into 1 PDF
system(paste("/usr/bin/gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=skyvalgrad.pdf skyvalgrad-a.pdf skyvalgrad-b.pdf"))

