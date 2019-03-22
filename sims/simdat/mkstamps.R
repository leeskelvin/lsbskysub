#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
funpack = "/usr/bin/funpack"

# definitions
tpids = c("8283-38","9592-20")

# loop
for(i in 1:length(tpids)){
    
    n1a = paste0("v2/calexp-HSC-R-",tpids[i],".simulated-n1.fits.fz")
    n1b = paste0("v3/calexp-HSC-R-",tpids[i],".simulated-n1-nofaint.fits.fz")
    n4a = paste0("v2/calexp-HSC-R-",tpids[i],".simulated-n4.fits.fz")
    n4b = paste0("v3/calexp-HSC-R-",tpids[i],".simulated-n4-nofaint.fits.fz")
    abfiles = c(n1a,n1b,n4a,n4b)
    
    # loop/read
    abfile = paste0("~/Desktop/abdat-", tpids[i], ".rds")
    if(!file.exists(abfile)){
        abdat = {}
        for(j in 1:length(abfiles)){
            unlink("temp.fits")
            system(paste(funpack, "-O temp.fits", abfiles[j]))
            abdat = c(abdat, list(smooth2d(read.fitsim("temp.fits"),fwhm=3,filter="gauss")))
            unlink("temp.fits")
        }
        saveRDS(abdat, file=abfile)
    }else{
        cat("\nNote: ", abfile, " exists: loading\n", sep="")
        abdat = readRDS(abfile)
    }
    
    # dev
    png(file=paste0("simstamp-", tpids[i], ".png"), width=8, height=7.8, units="in", res=150)

    # par
    layout(cbind(c(1,2),c(3,4)))
    par("oma"=c(0.5,2,2,0.5))
    par("mar"=c(0.25,0.25,0.25,0.25))
    
    # loop
    for(j in 1:length(abdat)){
        
        scale.lo = -0.025
        scale.hi = 5
        aimage(abdat[[j]], col.map="sls", scale.type="log", axes=FALSE, scale.lo=scale.lo, scale.hi=scale.hi, xlab="", ylab="")
        if(j == 1){mtext(side=2, line=0.5, text="all simulated sources", cex=1.25)}
        if(j == 1){mtext(side=3, line=0.5, text="disk-like : n = 1", cex=1.25)}
        if(j == 2){mtext(side=2, line=0.5, text="bright sources only (excludes faint)", cex=1.25)}
        if(j == 3){mtext(side=3, line=0.5, text="spheroid-like : n = 4", cex=1.25)}
        
    }
    
    # finish up
    graphics.off()
    
}

# finish up
cat("\n")

