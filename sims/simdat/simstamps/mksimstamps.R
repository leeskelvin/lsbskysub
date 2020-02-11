#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
funpack = "/usr/bin/funpack"

# definitions
tpids = c("8283-38","9592-20")

# loop
for(i in 1:length(tpids)){

    n1a = paste0("../v5/calexp-HSC-R-",tpids[i],".simulated-n1-a.fits.fz")
    n1b = paste0("../v5/calexp-HSC-R-",tpids[i],".simulated-n1-b.fits.fz")
    n4a = paste0("../v5/calexp-HSC-R-",tpids[i],".simulated-n4-a.fits.fz")
    n4b = paste0("../v5/calexp-HSC-R-",tpids[i],".simulated-n4-b.fits.fz")
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
    png(file=paste0("simstamp-full-", tpids[i], ".png"), width=8, height=8*(4100/4200), units="in", res=155)

    # par
    layout(cbind(c(1,2),c(3,4)))
    par("oma"=c(0.5,2,2,0.5))

    # loop
    for(j in 1:length(abdat)){

        scale.lo = -0.025
        scale.hi = 5
        xdim = dim(abdat[[j]])[1]
        ydim = dim(abdat[[j]])[2]
        par("mar"=c(0.25,0.25,0.25,0.25))
        aimage(abdat[[j]], col.map="sls", scale.type="log", axes=FALSE, scale.lo=scale.lo, scale.hi=scale.hi, xlab="", ylab="")
        if(j == 1){mtext(side=2, line=0.5, text="all simulated sources", cex=1.25)}
        if(j == 1){mtext(side=3, line=0.5, text="disk-like : n = 1", cex=1.25)}
        if(j == 2){mtext(side=2, line=0.5, text="bright sources only (excludes faint)", cex=1.25)}
        if(j == 3){mtext(side=3, line=0.5, text="spheroid-like : n = 4", cex=1.25)}
        if(j == 1){
            lines(x=par("usr")[1]+c(0.05*xdim,(0.05*xdim)+(200/0.168)), y=par("usr")[3]+c(0.05*ydim,0.05*ydim), lwd=7.5, col="white", lend=1)
            text(x=par("usr")[1]+0.05*xdim, y=par("usr")[3]+0.125*ydim, lab="200 arcsec", col="white", adj=c(0,0.5), cex=1.5)
        }

    }

    # finish up
    graphics.off()

}

# loop
for(i in 1:length(tpids)){

    n1a = paste0("../v5/calexp-HSC-R-",tpids[i],".simulated-n1-a.fits.fz")
    n1b = paste0("../v5/calexp-HSC-R-",tpids[i],".simulated-n1-b.fits.fz")
    n4a = paste0("../v5/calexp-HSC-R-",tpids[i],".simulated-n4-a.fits.fz")
    n4b = paste0("../v5/calexp-HSC-R-",tpids[i],".simulated-n4-b.fits.fz")
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

    # subimages
    xcen = c(370, 740)
    ycen = c(2650, 2310)
    xdim = c(535, 535)
    ydim = c(535, 535)
    xlo = round(xcen[i] - ((xdim[i]+1)/2))
    xhi = round(xcen[i] + ((xdim[i]+1)/2))
    ylo = round(ycen[i] - ((ydim[i]+1)/2))
    yhi = round(ycen[i] + ((ydim[i]+1)/2))

    # dev
    png(file=paste0("simstamp-zoom-", tpids[i], ".png"), width=8, height=8*(4100/4200), units="in", res=155)

    # par
    layout(cbind(c(1,2),c(3,4)))
    par("oma"=c(0.5,2,2,0.5))

    # loop
    for(j in 1:length(abdat)){

        scale.lo = -0.025
        scale.hi = 5
        par("mar"=c(0.25,0.25,0.25,0.25))
        aimage(abdat[[j]], col.map="sls", scale.type="log", axes=FALSE, scale.lo=scale.lo, scale.hi=scale.hi, xlab="", ylab="", xdim=xdim[1], ydim=ydim[1], xcen=xcen[1], ycen=ycen[1])
        if(j == 1){mtext(side=2, line=0.5, text="all simulated sources", cex=1.25)}
        if(j == 1){mtext(side=3, line=0.5, text="disk-like : n = 1", cex=1.25)}
        if(j == 2){mtext(side=2, line=0.5, text="bright sources only (excludes faint)", cex=1.25)}
        if(j == 3){mtext(side=3, line=0.5, text="spheroid-like : n = 4", cex=1.25)}
        if(j == 1){
            lines(x=par("usr")[1]+c(0.05*xdim[1],(0.05*xdim[1])+(25/0.168)), y=par("usr")[3]+c(0.05*ydim[1],0.05*ydim[1]), lwd=7.5, col="white", lend=1)
            text(x=par("usr")[1]+0.05*xdim[1], y=par("usr")[3]+0.125*ydim[1], lab="25 arcsec", col="white", adj=c(0,0.5), cex=1.5)
        }

    }

    # finish up
    graphics.off()

}

# finish up
cat("\n")
