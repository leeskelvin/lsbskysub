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
ydats = list(dat$skymean[,ordera],dat$skymean[,orderb])
pdfnames = paste0("skyval-", c("a","b","a5","b5"), ".pdf")
ylimlo = c(29.6,32.5,29.6,32.5)
ylimhi = c(27.6,28.5,27.6,28.5)

# par
cex = 1.5
lwd = 1.5
metpch = c(0,3,2,1,4,8,6,5,10,12)
metcol = c(2,2,2,2,3,3,3,3,1,1)
simsources = paste0("Simulating ", c("All Sources","Bright Only (No EBL)","All","Bright Only (No EBL)"))

# loop
for(i in 1:length(ydats)){
    
    # dev
    cairo_pdf(file=pdfnames[i], width=8, height=6)
    
    # par
    layout(rbind(c(1,2),c(3,4)))
    palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
    par("mar"=c(0.25,0.25,0.25,0.25))
    par("oma"=c(1,4.5,7.5,4.5))
    
    # loop
    for(j in 1:ncol(ydats[[i]])){
        
        # base plot setup
        if(j==1){labs = c(2)}
        if(j==2){labs = c(4)}
        if(j==3){labs = c(2)}
        if(j==4){labs = c(4)}
        aplot(NA, xlim=c(1-0.25,nrow(ydats[[1]])+0.25), ylim=c(ylimlo[i],ylimhi[i]), xlab="", ylab="", las=1, side=NA, log="", labels=labs, tick=FALSE, bty="n")
        abline(h=seq(27.5,35,by=0.5), col="grey75", lty=2, lend=1)
        #abline(v=c(0.00001,0.0001,0.001,0.01,0.1,1), col="grey75", lty=2, lend=1)
        aaxes(side=c(2,4), labels=labs, ynmin=1, las=1, mgp=c(2,0.5,0))
        if(j%in%c(1,2)){mtext(side=3, line=0.25, text=c("low density","high density")[j], cex=1)}
        if(j%in%c(1,2)){labtext="exponential"}else{labtext="de Vaucouleurs"}
        label("topleft", lab=labtext, inset=0.5, outline="white")
        abox()
        
        # points
        ydat = suppressWarnings(fn(ydats[[i]][,j]))
        toolow = is.na(ydat) | ydat>35
        if(any(toolow)){
            ydat[toolow] = par("usr")[3]-0.5
        }
        apoints(1:nrow(ydats[[i]]), ydat, pch=metpch, lwd=lwd, cex=cex, lend=1, col=metcol)
        if(length(toolow) > 0){
            for(k in which(toolow)){
                arrows(x0=(1:nrow(ydats[[i]]))[k], y0=ydat[k], y1=par("usr")[3], lwd=lwd, cex=cex, lend=1, col=metcol[k], length=0.075)
            }
        }
        
    }
    
    # labels & legend
    par("xpd"=NA)
    #mtext(side=1, line=2, text="sky estimation method", outer=T)
    mtext(side=3, line=1, text=simsources[i], outer=T)
    mtext(side=2, line=2.5, text=bquote(paste("mean subtracted sky level / mag ", arcsec^{-2})), outer=T)
    alegend("top", legend=names(dat$files), ncol=4, byrow=T, inset=0.5, outer=TRUE, seg.len=0.8, seg.gap=0.4,  type=setNames(apply(cbind(pch=metpch,lwd=lwd,col=metcol,cex=cex), 1, as.list), rep("p",length(dat$files))), bty="o", cex=0.9, box.pad=0.25, line.spacing=1.25)
    
    # finish up
    graphics.off()
    
}

# merge into 1 PDF
system(paste("/usr/bin/gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=skyval.pdf skyval-a.pdf skyval-b.pdf"))

