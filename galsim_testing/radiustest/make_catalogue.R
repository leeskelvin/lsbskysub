#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
ns = rev(c("0.5","1.0","2.0","4.0","6.0"))
ellips = seq(0,0.95,by=0.01)
xcen = ycen = 151

# loop
for(j in 1:length(ns)){
    
    # sersic index
    feed = readLines("galsim.config")
    feed[grep("n :", feed)] = paste("    n :", ns[j])
    cat(feed, sep="\n", file="galsim.config")
    
    # loop
    res = {}
    for(i in 1:length(ellips)){
        
        # read, modify, and write GalSim feedme config file
        feed = readLines("galsim.config")
        feed[grep("type : QBeta", feed)+1] = paste("        q :", 1-ellips[i])
        cat(feed, sep="\n", file="galsim.config")
        
        # make image with galsim
        unlink("galsim.fits")
        system("/usr/local/bin/galsim galsim.config")
        
        # run Source Extractor
        system("/usr/bin/sextractor -c sex.config -THRESH_TYPE ABSOLUTE -DETECT_THRESH 0.25 -ANALYSIS_THRESH 0.25 galsim.fits")
        
        # read cats
        sexdat = read.table("sextractor.cat")
        colnames(sexdat) = c("NUMBER", "X_IMAGE", "Y_IMAGE", "FLUX_AUTO", "MAG_AUTO", "A_IMAGE", "B_IMAGE", "KRON_RADIUS", "PETRO_RADIUS", "FLUX_RADIUS", "ELLIPTICITY", "THETA_IMAGE", "BACKGROUND", "THRESHOLD", "ISOAREA_IMAGE", "CLASS_STAR", "FLUX_SPHEROID", "MAG_SPHEROID", "SPHEROID_REFF_IMAGE", "SPHEROID_ASPECT_IMAGE", "SPHEROID_THETA_IMAGE", "SPHEROID_SERSICN", "CHI2_MODEL", "FLAGS_MODEL")
        offset = sqrt(((sexdat[,"X_IMAGE"] - xcen)^2) + ((sexdat[,"Y_IMAGE"] - ycen)^2))
        sexdat = sexdat[which.min(offset),,drop=FALSE]
        sexdat = cbind(N=as.numeric(ns[j]), ELLIP=ellips[i], R=15, A=sqrt((15^2)/(1-ellips[i])), B=sqrt((15^2)*(1-ellips[i])), sexdat)
        res = rbind(res, sexdat)
        
        # clean up
        unlink(c("sextractor.cat"))
        
    }

    # save results
    write.csv(res, file=paste0("sextractor-n",ns[j],".csv"), row.names=FALSE, quote=FALSE)
    
}

