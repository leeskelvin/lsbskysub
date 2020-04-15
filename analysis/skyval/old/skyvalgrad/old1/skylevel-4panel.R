#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
files = c(  "../../source_extraction/sex_default/stats_sex_default.csv"
            ,"../../source_extraction/sex_optimised/stats_sex_optimised.csv"
            ,"../../source_extraction/sex_dilated/stats_sex_dilated.csv"
            ,"../../source_extraction/sex_modelled/stats_sex_modelled.csv"
            ,"../../source_extraction/gnuastro_default/stats_gnuastro_default.csv"
            ,"../../source_extraction/gnuastro_optimised/stats_gnuastro_optimised.csv"
            ,"../../source_extraction/gnuastro_dilated/stats_gnuastro_dilated.csv"
            ,"../../source_extraction/gnuastro_modelled/stats_gnuastro_modelled.csv"
)
methods = c( "SExtractor default"
            ,"SExtractor optimised"
            ,"SExtractor w. dilated masks"
            ,"SExtractor w. modelled masks"
            ,"Gnuastro default"
            ,"Gnuastro optimised"
            ,"Gnuastro w. dilated masks"
            ,"Gnuastro w. modelled masks"
)

# data setup
dets = mats = areafracs = areameans = areafrac5s = areamean5s = means = stds = {}
for(i in 1:length(files)){
    if(file.exists(files[i])){
        dat = read.csv(files[i], stringsAsFactors=FALSE)
        dets = rbind(dets, dat[,"NDET"])
        mats = rbind(mats, dat[,"NMATCH"])
        areafracs = rbind(areafracs, dat[,"AREAFRAC"])
        areameans = rbind(areameans, dat[,"AREAMEAN"])
        areafrac5s = rbind(areafrac5s, dat[,"AREAFRAC5"])
        areamean5s = rbind(areamean5s, dat[,"AREAMEAN5"])
        means = rbind(means, dat[,"SKYMEAN"])
        stds = rbind(stds, dat[,"SKYSTD"])
    }else{
        dets = rbind(dets, rep(NA,8))
        mats = rbind(mats, rep(NA,8))
        areafracs = rbind(areafracs, rep(NA,8))
        areameans = rbind(areameans, rep(NA,8))
        areafrac5s = rbind(areafrac5s, rep(NA,8))
        areamean5s = rbind(areamean5s, rep(NA,8))
        means = rbind(means, rep(NA,8))
        stds = rbind(stds, rep(NA,8))
    }
}
rownames(dets) = rownames(mats) = rownames(areafracs) = rownames(areameans) = rownames(areafrac5s) = rownames(areamean5s) = rownames(means) = rownames(stds) = paste0("method",1:8)
colnames(dets) = colnames(mats) = colnames(areafracs) = colnames(areameans) = colnames(areafrac5s) = colnames(areamean5s) = colnames(means) = colnames(stds) = dat[,"ID"]
fn = function(flux){-2.5*log10(flux/(0.168^2))+27}
ordera = c(5,7,1,3)
orderb = c(6,8,2,4)
xdats = list(areafracs[,ordera], areafracs[,orderb], areafrac5s[,ordera], areafrac5s[,orderb])
ydats = list(means[,ordera], means[,orderb], means[,ordera], means[,orderb])
adats = list(areameans[,ordera], areameans[,orderb], areamean5s[,ordera], areamean5s[,orderb])
pdfnames = paste0("skylevel-", c("a","b","a5","b5"), ".pdf")
labels = paste0("Simulated Sources: ", c("All","Bright","All","Bright"))
ylabs = paste0("mean fractional recovered area ", c("","",rep("(largest 5 matched sources only)",2)))

# loop
for(i in 1:length(xdats)){
    
    # dev
    cairo_pdf(file=pdfnames[i], width=8, height=6)
    
    # par
    layout(matrix(1:4,byrow=T,ncol=2))
    palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
    par("mar"=c(0.25,0.25,0.25,0.25))
    par("oma"=c(4,5.5,6.5,4))
    cex = 2
    lwd = 2
    pch = c(0,1,2,3,4,5,6,8)
    
    # loop
    for(j in 1:ncol(xdats[[i]])){
        
        # base plot
        labs = {}; if(j %in% c(3,4)){labs = c(labs,1)}; if(j %in% c(1,3)){labs = c(labs,2)}
        aplot(NA, xlim=c(0.00225,1), ylim=c(-0.0015,0.0135), xlab="", ylab="", las=1, side=1:3, log="x", labels=labs, ynmin=4, bty="n")
        aaxis(side=4, fn=fn, at=c(28:38), labels=FALSE, nmin=1)
        if(j %in% c(2,4)){aaxis(side=4, fn=fn, at=c(28,29,30,31), tick=FALSE, las=1)}
        if(j %in% c(2,4)){mtext(side=4, at=0.00005, line=0.3, las=1, text="∞")}
        
        # grid
        #abline(h=0, col="grey50", lty=1, lend=1)
        abline(h=c(-0.005,0,0.005,0.01,0.015), col="grey75", lty=2, lend=1)
        abline(v=c(0.001,0.01,0.1,1), col="grey75", lty=2, lend=1)
        
        # points
        apoints(xdats[[i]][,j], ydats[[i]][,j], pch=pch, lwd=lwd, cex=cex, lend=1, col=c(rep(2,4),rep(3,4)))
        
        # connecting lines
        for(k in c(2,3,4,6,7,8)){
            base = ifelse(k %in% c(2,3,4), 1, 5)
            kx = c(xdats[[i]][base,j],xdats[[i]][k,j])
            ky = c(ydats[[i]][base,j],ydats[[i]][k,j])
            lines(x=kx, y=ky, lwd=2, lend=1, col=1)#c(rep(2,4),rep(3,4))[k])
#            if(!is.na(diff(kx))){
#                text(x=kx[2], y=ky[2], lab=paste0(formatC(diff(kx),format="f",digits=3),"\n",formatC(diff(ky),format="f",digits=3)), adj=c(0.5,1.5))
#                text(x=kx[2], y=ky[2], lab=round(adats[[i]][k,j]), adj=c(0.5,-1))
#            }
        }
        
        # finish up
        #label("top", lab=colnames(xdats[[i]])[j], cex=1.5, inset=0.5)
        if(j %in% c(1,2)){mtext(side=3, line=0.25, text=c("disk-like","spheroid-like")[j], cex=1)}
        if(j %in% c(1,3)){mtext(side=2, line=2.5, text=c("high density","","low density")[j], cex=1)}
        abox()
        
    }
    
    # labels & legend
    par("xpd"=NA)
    mtext(side=1, line=2, text=ylabs[i], outer=T)
    mtext(side=2, line=3.75, text=bquote(paste("mean sky level / ADU ", pixel^{-2})), outer=T)
    mtext(side=3, line=1, text=labels[i], outer=T)
    mtext(side=4, line=2, text=bquote(paste("mean sky level / mag ", arcsec^{-2})), outer=T)
    alegend("top", legend=methods, ncol=4, byrow=T, inset=0.5, outer=TRUE, seg.len=0.25*cex, seg.gap=0.25*cex,  type=setNames(apply(cbind(pch=pch,lwd=lwd,col=c(rep(2,4),rep(3,4)),cex=cex), 1, as.list), rep("p",8)), bty="o", cex=1.1, box.pad=0.1)

    # finish up
    graphics.off()
    
    # quick analysis PNG
    system(paste0("/usr/bin/convert -density 300 ", pdfnames[i], " -quality 90 temp", i, ".png"))
    
}

# PNG update
system("mv skylevel.png skylevel-old.png")
system("/usr/bin/montage temp1.png temp2.png temp3.png temp4.png -geometry 800x600 skylevel.png")
unlink(c("temp1.png","temp2.png","temp3.png","temp4.png"))

