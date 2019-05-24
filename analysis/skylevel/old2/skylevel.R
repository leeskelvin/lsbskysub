#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
files = c(  "SExtractor default"="../../source_extraction/sex_default/stats_sex_default.csv"
            ,"SExtractor optimised"="../../source_extraction/sex_optimised/stats_sex_optimised.csv"
            ,"SExtractor w. dilated masks"="../../source_extraction/sex_dilated/stats_sex_dilated.csv"
            ,"SExtractor w. modelled masks"="../../source_extraction/sex_modelled/stats_sex_modelled.csv"
            ,"Gnuastro default"="../../source_extraction/gnuastro_default/stats_gnuastro_default.csv"
            ,"Gnuastro optimised"="../../source_extraction/gnuastro_optimised/stats_gnuastro_optimised.csv"
            ,"Gnuastro w. dilated masks"="../../source_extraction/gnuastro_dilated/stats_gnuastro_dilated.csv"
            ,"Gnuastro w. modelled masks"="../../source_extraction/gnuastro_modelled/stats_gnuastro_modelled.csv"
            ,"DM stack default"="../../source_extraction/dmstack_default/stats_dmstack_default.csv"
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
        dets = rbind(dets, rep(NA,ncol(dets)))
        mats = rbind(mats, rep(NA,ncol(dets)))
        areafracs = rbind(areafracs, rep(NA,ncol(dets)))
        areameans = rbind(areameans, rep(NA,ncol(dets)))
        areafrac5s = rbind(areafrac5s, rep(NA,ncol(dets)))
        areamean5s = rbind(areamean5s, rep(NA,ncol(dets)))
        means = rbind(means, rep(NA,ncol(dets)))
        stds = rbind(stds, rep(NA,ncol(dets)))
    }
}
rownames(dets) = rownames(mats) = rownames(areafracs) = rownames(areameans) = rownames(areafrac5s) = rownames(areamean5s) = rownames(means) = rownames(stds) = paste0("method",1:length(files))
colnames(dets) = colnames(mats) = colnames(areafracs) = colnames(areameans) = colnames(areafrac5s) = colnames(areamean5s) = colnames(means) = colnames(stds) = dat[,"ID"]
fn = function(flux){-2.5*log10(flux/(0.168^2))+27}
ordera = c(1,3,5,7)
orderb = c(2,4,6,8)
xdats = list(areafracs[,ordera], areafracs[,orderb], areafrac5s[,ordera], areafrac5s[,orderb])
ydats = list(means[,ordera], means[,orderb], means[,ordera], means[,orderb])
adats = list(areameans[,ordera], areameans[,orderb], areamean5s[,ordera], areamean5s[,orderb])
pdfnames = paste0("skylevel-", c("a","b","a5","b5"), ".pdf")
cex = 1.5
lwd = 1.5
metpch = c(0,1,2,3,4,5,6,8,10)
colcol = c(2,3,2,3)
alabs = paste0("mean fractional recovered area", c("","",rep(" (largest 5 matched sources only)",2)))
simsources = paste0("Simulated Sources: ", c("All","Bright","All","Bright"))

# loop
for(i in 1:length(xdats)){
    
    # dev
    cairo_pdf(file=pdfnames[i], width=8, height=6)
    
    # par
    layout(cbind(1,2))
    palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
    par("mar"=c(0.25,0.25,0.25,0.25))
    par("oma"=c(4,4.5,6.5,4))
    
    # loop
    for(j in 1:ncol(xdats[[i]])){
        
        # base plot setup
        if(j %in% c(1,3)){
            if(j==1){labs = c(1,2)}
            if(j==3){labs = c(1)}
            aplot(NA, xlim=c(0.00225,1), ylim=c(-0.0010,0.014), xlab="", ylab="", las=1, side=1:3, log="x", labels=labs, ynmin=4, bty="n")
            abline(h=c(-0.005,0,0.005,0.01,0.015), col="grey75", lty=2, lend=1)
            abline(v=c(0.001,0.01,0.1,1), col="grey75", lty=2, lend=1)
            aaxis(side=4, fn=fn, at=c(28:38), labels=FALSE, nmin=1)
            if(j==3){aaxis(side=4, fn=fn, at=c(28,29,30,31), tick=FALSE, las=1)}
            if(j==3){mtext(side=4, at=0.00005, line=0.25, las=1, text="∞", cex=1.25)}
            mtext(side=3, line=0.25, text=c("low density","","high density")[j], cex=1)
            abox()
            if(j==1){alegend("topleft", legend=c("disk like","spheroid like"), ncol=1, inset=0.5, seg.len=0.8, seg.gap=0.4, type=setNames(apply(cbind(pch=0,lwd=lwd,col=c(2,3),cex=cex,border=NA), 1, as.list), rep("f",2)), bty="o", cex=0.9, box.pad=0.1)}
        }
        
        # points
        apoints(xdats[[i]][,j], ydats[[i]][,j], pch=metpch, lwd=lwd, cex=cex, lend=1, col=colcol[j])
        
#        # connecting lines
#        for(k in c(2,3,4,6,7,8)){
#            base = ifelse(k %in% c(2,3,4), 1, 5)
#            kx = c(xdats[[i]][base,j],xdats[[i]][k,j])
#            ky = c(ydats[[i]][base,j],ydats[[i]][k,j])
#            lines(x=kx, y=ky, lwd=2, lend=1, col=1)#c(rep(2,4),rep(3,4))[k])
#        }
        
    }
    
    # labels & legend
    par("xpd"=NA)
    mtext(side=1, line=2, text=alabs[i], outer=T)
    mtext(side=2, line=2.75, text=bquote(paste("mean sky level / ADU ", pixel^{-2})), outer=T)
    mtext(side=3, line=1, text=simsources[i], outer=T)
    mtext(side=4, line=2, text=bquote(paste("mean sky level / mag ", arcsec^{-2})), outer=T)
    alegend("top", legend=names(files), ncol=4, byrow=T, inset=0.5, outer=TRUE, seg.len=0.8, seg.gap=0.4,  type=setNames(apply(cbind(pch=metpch,lwd=lwd,col=1,cex=cex), 1, as.list), rep("p",length(files))), bty="o", cex=0.9, box.pad=0.25, line.spacing=1.25)

    # finish up
    graphics.off()
    
    # quick analysis PNG
    system(paste0("/usr/bin/convert -density 300 ", pdfnames[i], " -quality 90 temp", i, ".png"))
    
}

# PNG update
system("mv skylevel.png skylevel-old.png")
system("/usr/bin/montage temp1.png temp2.png temp3.png temp4.png -geometry 800x600 skylevel.png")
unlink(c("temp1.png","temp2.png","temp3.png","temp4.png"))

