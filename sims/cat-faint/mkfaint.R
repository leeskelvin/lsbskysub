#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
set.seed(5)

# definitions
cats = paste0("../../hsc_data/numcounts/", grep(".csv", dir("../../hsc_data/numcounts/"), value=TRUE))
pixelsize = 0.168 # arcsec/pixel
#n = 4 # sersic index
n = as.numeric(commandArgs(TRUE)); if(length(n) == 0){stop("specify n")}
#fluxfrac = 0.995 # flux fraction holding stamp box
mulim = 40 # surface brightness limit
stampextra = 0 # extra addition to stamp_size
stampmin = 11 # minimum stamp size

# loop
for(i in 1:length(cats)){
    
    # setup
    dat = read.csv(cats[i], stringsAsFactors=FALSE)
    
    # define bright sources and output results data frame
    magbright = 22
    bw = 0.5
    dat = dat[dat[,"NUM"]>0 & dat[,"MAG"]>(magbright+bw/2),]
    out = {}
    
    # loop
    for(j in 1:nrow(dat)){
        
        # setup
        binnum = ceiling(dat[j,"NUM"])
        x = runif(binnum, min=0.5, max=4200.5)
        y = runif(binnum, min=0.5, max=4100.5)
        mags = dat[j,"MAG"] + runif(binnum, min=-bw/2, max=bw/2) # r-band
        flux = 10^(-0.4 * (mags - 27)) # counts
        hlrbase = pmax((-0.15 * mags) + 4.25, 1*pixelsize) # minimum size of 1 pixel
        hlrzone = runif(binnum, min=-0.25, max=0.25)
        hlrquan = pmin(floor((hlrzone+0.25)*8),3)+1
        half_light_radius = hlrbase + (hlrzone*hlrbase) # arcsec
        ellip = pmin(pmax(0.4 + runif(binnum,min=-0.2,max=0.2), 0), 1)
        q = 1 - ellip # axis ratio
        theta = runif(binnum, min=-90, max=90) # degrees
        #stamp_size = ceiling(2*sersic.fluxfrac2r(fluxfrac, n=n, r.ref=half_light_radius/pixelsize, fluxfrac.ref=0.5)) + stampextra # pixels
        stamp_size = 1 + stampextra + 2*ceiling(sersic.mu2r(mu=mulim, mag=mags, n=n, re=half_light_radius/pixelsize, e=ellip)) # pixels
        if(any(stamp_size < stampmin)){stamp_size[stamp_size<stampmin] = stampmin}
        # digits: x=1, y=1, flux=3, half_light_radius=3, q=2, theta=1, n=NA, stamp_size=NA
        out = rbind(out, cbind(x=formatC(x,format="f",digits=1), y=formatC(y,format="f",digits=1), flux=formatC(flux,format="f",digits=3), half_light_radius=formatC(half_light_radius,format="f",digits=3), q=formatC(q,format="f",digits=2), theta=formatC(theta,format="f",digits=1), n=n, stamp_size=stamp_size))
        
    }
    
    # write
    outname = paste0(strsplit(basename(cats[i]), ".extra.csv")[[1]], ".cat-faint-n",n,".dat")
    write.table(out, file=outname, sep=" ", row.names=FALSE, quote=FALSE, col.names=FALSE)
    
}

# screen output
cat("\n")
print(data.frame(COLUMN=1:ncol(out)-1, NAME=colnames(out)), row.names=rep("",8))
cat("\n")

