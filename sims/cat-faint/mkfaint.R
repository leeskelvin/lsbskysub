#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
set.seed(5)

# definitions
n = as.numeric(commandArgs(TRUE)); if(length(n) == 0){stop("specify n")}
cats = paste0("../../hsc_data/numcounts/", grep(".csv", dir("../../hsc_data/numcounts/"), value=TRUE))
pixelsize = 0.168 # arcsec/pixel

# loop
for(i in 1:length(cats)){
    
    # setup
    dat = read.csv(cats[i], stringsAsFactors=FALSE)
    outname = paste0(strsplit(basename(cats[i]), ".extra.csv")[[1]], ".cat-faint-n",n,".csv")
    
    # define bright sources and output results data frame
    magbright = 22
    bw = 0.5
    dat = dat[dat[,"NUM"]>0 & dat[,"MAG"]>(magbright+bw/2),]
    
    # loop
    out = {}
    for(j in 1:nrow(dat)){
        
        # setup
        binnum = ceiling(dat[j,"NUM"])
        
        # x/y position
        x = runif(binnum, min=0.5, max=4200.5)
        y = runif(binnum, min=0.5, max=4100.5)
        
        # luminosity
        mags = dat[j,"MAG"] + runif(binnum, min=-bw/2, max=bw/2) # r-band
        luminosity_counts = 10^(-0.4 * (mags - 27)) # counts
        
        # half light radius (circularised)
        hlrbase = pmax((-0.15 * mags) + 4.25, 1*pixelsize) # minimum size of 1 pixel
        hlrzone = runif(binnum, min=-0.25, max=0.25)
        #hlrquan = pmin(floor((hlrzone+0.25)*8),3)+1
        half_light_radius_arcsec = hlrbase + (hlrzone*hlrbase) # arcsec
        half_light_radius_pixel = half_light_radius_arcsec / pixelsize # pixel
        
        # axis ratio / position angle
        ellip = pmin(pmax(0.4 + runif(binnum,min=-0.2,max=0.2), 0), 1)
        q = 1 - ellip # axis ratio
        theta = runif(binnum, min=-90, max=90) # degrees
        
        # output catalogue
        # digits: x=1, y=1, luminosity_counts=5, hlr_pixels=3, q=2, theta=1, n=NA
        out = rbind(out, cbind(
            x = formatC(x,format="f",digits=1)
            , y = formatC(y,format="f",digits=1)
            , luminosity_counts = formatC(luminosity_counts,format="f",digits=5)
            , hlr_pixel = formatC(half_light_radius_pixel,format="f",digits=3)
            , q = formatC(q,format="f",digits=2)
            , theta = formatC(theta,format="f",digits=1)
            , n = n
        ))
        
    }
    
    # write
    write.csv(out, file=outname, row.names=FALSE, quote=FALSE)
    
}

# finish up
cat("\n")

