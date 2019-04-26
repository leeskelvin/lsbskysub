#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
#files = system("ls -1 ../../source_extraction/*/stats*.csv", intern=TRUE)
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
regions = c( "low density disk-like (all)"
            ,"low density disk-like (bright)"
            ,"low density sph-like (all)"
            ,"low density sph-like (bright)"
            ,"high density disk-like (all)"
            ,"high density disk-like (bright)"
            ,"high density sph-like (all)"
            ,"high density sph-like (bright)"
)

# data read loop
nums = fluxes = {}
for(i in 1:length(files)){
    if(file.exists(files[i])){
        dat = read.csv(files[i], stringsAsFactors=FALSE)
        nums = rbind(nums, dat[,"NOBJ"])
        fluxes = rbind(fluxes, dat[,"SKYMEAN"])
    }else{
        nums = rbind(nums, rep(NA,8))
        fluxes = rbind(fluxes, rep(NA,8))
    }
}
rownames(nums) = rownames(fluxes) = paste0("method",1:8)
colnames(nums) = colnames(fluxes) = dat[,"ID"]
fn = function(flux){-2.5*log10(flux/(0.168^2))+27}

# dev
cairo_pdf(file="skylevel.pdf", width=8, height=10)
palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))

# par
layout(matrix(1:8,byrow=T,ncol=2))
par("mar"=c(0.25,0.25,0.25,0.25))
par("oma"=c(4,4.5,5.5,4.5))
cex = 2.5
lwd = 2
pch = c(0,1,2,3,4,5,6,8)

# loop
for(i in 1:ncol(nums)){
    
    # plot
    labs = {}
    if(i %in% c(7,8)){labs = c(labs,1)}
    if(i %in% c(1,3,5,7)){labs = c(labs,2)}
    #if(i %in% c(1,2)){labs = c(labs,3)}
    aplot(NA, xlim=c(2000,20000), ylim=c(-0.00025,0.015), xlab="", ylab="", las=1, side=1:3, log="x", labels=labs, ynmin=4, bty="n")
    aaxis(side=4, fn=fn, at=c(28:38), labels=FALSE, nmin=1)
    if(i %in% c(2,4,6,8)){
        aaxis(side=4, fn=fn, at=c(28,29,30,31), tick=FALSE, las=1)
    }
    abline(h=0, lwd=1.5, col="grey75", lty=2, lend=1)
    
    # points
    apoints(nums[,i], fluxes[,i], pch=pch, lwd=lwd, cex=cex, lend=1, col=c(rep(2,4),rep(3,4)))
    
    # finish up
    label("top", lab=regions[i], cex=1.5, inset=0.5)
    abox()
    
}

# labels & legend
par("xpd"=NA)
mtext(side=1, line=2, text="number of detected objects", outer=T)
mtext(side=2, line=3, text="mean sky level / ADU", outer=T)
mtext(side=4, line=2, text=bquote(paste("mean sky level / mag ", arcsec^{-2})), outer=T)
alegend("top", legend=methods, ncol=4, byrow=T, inset=0.5, outer=TRUE, seg.len=0.15*cex, seg.gap=0.25*cex,  type=setNames(apply(cbind(pch=pch,lwd=lwd,col=c(rep(2,4),rep(3,4)),cex=cex), 1, as.list), rep("p",8)), bty="o", cex=1.25)

# finish up
graphics.off()

