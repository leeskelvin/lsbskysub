#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# software
funpack = "/usr/bin/funpack"
gzip = "/bin/gzip"

# definitions
zlo = 30
zhi = 27
cbmagsep = 0.5
cbnumlabels = ((zlo-zhi) / cbmagsep) + 1
ztype = 'lin'
line = 0.5
colmap = "grey"
colinvert = FALSE
block = 100
fn = function(flux){-2.5*log10(flux/(0.168^2))+27}
ifn = function(mag){(10^(-0.4*(mag-27)))*(0.168^2)}
cex = 0.85

# map locations
mapids = c("sex_default", "sex_optimised", "sex_dilated", "sex_modelled", "gnuastro_default", "gnuastro_optimised", "gnuastro_dilated", "gnuastro_modelled", "dmstack_default", "dmstack_optimised")
#mapnames = c("SExtractor\ndefault", "SExtractor\nmodified", "SExtractor\ndil. msk", "SExtractor\nmodel msk", "Gnuastro\ndefault", "Gnuastro\nmodified", "Gnuastro\ndil. msk", "Gnuastro\nmodel msk", "LSST Pipelines\nc. 2018", "LSST Pipelines\nc. 2020")
mapnames = c("\ndefault", "\nmodified", "\ndil. msk", "\nmodel msk", "\ndefault", "\nmodified", "\ndil. msk", "\nmodel msk", "\nP6", "\nS128")
simids = c("denlo1a", "denlo4a", "denhi1a", "denhi4a")
simnames = c("\nexponential", "\nde Vauc.", "\nexponential", "\nde Vauc.")

# png
png(file=paste0("skymaps.png"), width=5, height=8.75, units="in", res=300)

# par
par("mar"=c(0.1,0.1,0.1,0.1))
par("oma"=c(0,4,4,2))
layout(cbind(matrix(1:(length(mapids)*length(simids)), ncol=4, byrow=TRUE),41))

# loop over each software type
magvals = {}
for(i in 1:length(mapids)){

    # setup
    mapdir = paste0("../../source_extraction/", mapids[i], "/map/")

    # loop over each simulated image type
    magvalsrow = {}
    for(j in 1:length(simids)){

        # setup
        cat("     \r", j+((i-1)*4), "/40", sep="")
        mapfile = paste0(mapdir, simids[j], ".map.fits")
        mapfilegz = paste0(mapfile, ".gz")
        unlink(mapfile)
        system(paste0(gzip, " -d -k ", mapfilegz))

        # data
        skydat = read.fitsim(mapfile, hdu=3)
        skydatsmall = regrid(skydat, fact=1/block) / (block*block)

        # mags
        magmap = suppressWarnings(fn(skydatsmall))
        #suppressWarnings(print(range(magmap, na.rm=TRUE)))

        # plot
        aimage(magmap, col.map=colmap, scale.type=ztype, axes=FALSE, scale.lo=zlo, scale.hi=zhi, xlab="", ylab="", smooth.fwhm=0, col.invert=colinvert)

        # extra bells and whistles
        if(i==1){
            mtext(side=3, line=line, text=simnames[j], cex=cex)
        }
        if(j==1){
            mtext(side=2, line=line, text=mapnames[i], cex=cex)
        }

        # finish up
        unlink(mapfile)
        magvalsrow = c(magvalsrow, mean(magmap, na.rm=TRUE))

    }

    # finish up
    magvals = rbind(magvals, magvalsrow)

}

# legend
plot(NA, xlim=c(0,1), ylim=c(0,1), axes=FALSE)
col.bar(x="topleft", seg.num=249, n=cbnumlabels, scale.type=ztype, scale.lo=zlo, scale.hi=zhi, col.map=colmap, col.invert=colinvert, bar.length=1, seg.width=1, box.lwd=5, cex=cex*1.25, inset=0, format='f', digits=1)
mtext(side=4, line=0.6, text=bquote(paste(mu, " / mag ", "arcsec"^{-2})), cex=cex*1.25)

# final outer labels
par("mar"=c(0,0,0,0))
par("oma"=c(0,0,0,0))
layout(1)
arrowlength = 0.02
xlabline = -1.25
xat = -0.02
ysex = 0.773 #; abline(h=ysex)
ygnu = 0.365 #; abline(h=ygnu)
ydm = 0.061 #; abline(h=ydm)
mtext(side=2, line=xlabline, at=ysex, text="Source Extractor", cex=cex)
arrows(x0=xat, y0=ysex+0.08, y1=ysex+0.185, length=arrowlength, angle=90, code=2, lend=1)
arrows(x0=xat, y0=ysex-0.08, y1=ysex-0.185, length=arrowlength, angle=90, code=2, lend=1)
#lines(x=c(xat,xat), y=c(ysex-0.05,ysex-0.15))
mtext(side=2, line=xlabline, at=ygnu, text="Gnuastro", cex=cex)
arrows(x0=xat, y0=ygnu+0.05, y1=ygnu+0.185, length=arrowlength, angle=90, code=2, lend=1)
arrows(x0=xat, y0=ygnu-0.05, y1=ygnu-0.185, length=arrowlength, angle=90, code=2, lend=1)
mtext(side=2, line=xlabline, at=ydm, text="LSST Pipelines", cex=cex)
arrows(x0=xat, y0=ydm+0.065, y1=ydm+0.075, length=arrowlength, angle=90, code=2, lend=1)
arrows(x0=xat, y0=ydm-0.065, y1=ydm-0.075, length=arrowlength, angle=90, code=2, lend=1)
ylabline = -1.25
yat = 1.02
xdenlo = 0.248 #; abline(v=xdenlo)
xdenhi = 0.623 #; abline(v=xdenhi)
mtext(side=3, line=ylabline, at=xdenlo, text="low density region", cex=cex)
#arrows(y0=yat, x0=xdenlo-0.14, x1=xdenlo-0.17, length=arrowlength, angle=90, code=2, lend=1)
#arrows(y0=yat, x0=xdenlo+0.14, x1=xdenlo+0.17, length=arrowlength, angle=90, code=2, lend=1)
mtext(side=3, line=ylabline, at=xdenhi, text="high density region", cex=cex)
#arrows(y0=yat, x0=xdenhi-0.14, x1=xdenhi-0.17, length=arrowlength, angle=90, code=2, lend=1)
#arrows(y0=yat, x0=xdenhi+0.14, x1=xdenhi+0.17, length=arrowlength, angle=90, code=2, lend=1)

# finish up
graphics.off()
cat("\b\b\b\b\b     \b\b\b\b\bDONE!\n")

# print sky statistics
colnames(magvals) = simids
rownames(magvals) = mapids
denlo = as.numeric(c(magvals[,"denlo1a"], magvals[,"denlo4a"]))
denhi = as.numeric(c(magvals[,"denhi1a"], magvals[,"denhi4a"]))
prof1 = as.numeric(c(magvals[,"denlo1a"], magvals[,"denhi1a"]))
prof4 = as.numeric(c(magvals[,"denlo4a"], magvals[,"denhi4a"]))
print(paste("mean density offset:", formatC(mean(denhi-denlo),format='f',digits=2)))
print(paste("                std:", formatC(sd(denhi-denlo),format='f',digits=2)))
print(paste("          min / max:", formatC(min(denhi-denlo),format='f',digits=2), '/', formatC(max(denhi-denlo),format='f',digits=2)))
print(paste("mean profile offset:", formatC(mean(prof4-prof1),format='f',digits=2)))
print(paste("                std:", formatC(sd(prof4-prof1),format='f',digits=2)))
print(paste("          min / max:", formatC(min(prof4-prof1),format='f',digits=2), '/', formatC(max(prof4-prof1),format='f',digits=2)))
