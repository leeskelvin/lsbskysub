#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
set.seed(5)

# definitions
n = as.numeric(commandArgs(TRUE)); if(length(n) == 0){stop("specify n")}
cats = paste0("../../hsc_data/numcounts/", grep(".csv", dir("../../hsc_data/numcounts/"), value=TRUE))
ells = read.csv("../../hsc_data/magellip/magellip.csv")
ells = cbind(ells, ELLID=ells[,"MAG"]+ells[,"QRAD"]/10)
pixelsize = 0.168 # arcsec/pixel

# loop
for(i in 1:length(cats)){
    
    # setup
    dat = read.csv(cats[i], stringsAsFactors=FALSE)
    base = strsplit(basename(cats[i]), ".extra.csv")[[1]]
    lores = read.fitsim(paste0(base, ".lores.fits"))
    outname = paste0(base, ".cat-bright-n",n,".csv")
    
    # define bright sources
    magbright = 22
    bw = 0.5
    dat = dat[dat[,"NUM"]>0 & dat[,"MAG"]<=(magbright+bw/2),]
    
    # loop
    out = {}
    for(j in 1:nrow(dat)){
        
        # setup
        binnum = ceiling(dat[j,"NUM"])
        
        # luminosity
        mags = dat[j,"MAG"] + runif(binnum, min=-bw/2, max=bw/2) # r-band
        luminosity_counts = 10^(-0.4 * (mags - 27)) # counts
        
        # half light radius (circularised)
        hlrbase = (-0.15 * mags) + 4.25
        hlrzone = runif(binnum, min=-0.25, max=0.25)
        hlrquan = pmin(floor((hlrzone+0.25)*8),3)+1
        half_light_radius_arcsec = hlrbase + (hlrzone*hlrbase) # arcsec
        half_light_radius_pixel = half_light_radius_arcsec / pixelsize # pixel
        
        # axis ratio / position angle
        ellid = dat[j,"MAG"] + hlrquan/10
        ellip = pmin(pmax(ells[match(ellid, ells[,"ELLID"]),"ELLIP"] + runif(binnum,min=-0.2,max=0.2), 0), 1)
        q = 1 - ellip # axis ratio
        theta = runif(binnum, min=-90, max=90) # degrees
        
        # output catalogue
        # digits: x=1, y=1, luminosity_counts=5, hlr_pixels=3, q=2, theta=1, n=NA
        out = rbind(out, cbind(
            x = NA
            , y = NA
            , luminosity_counts = formatC(luminosity_counts,format="f",digits=5)
            , hlr_pixel = formatC(half_light_radius_pixel,format="f",digits=3)
            , q = formatC(q,format="f",digits=2)
            , theta = formatC(theta,format="f",digits=1)
            , n = n
        ))
        
    }
    
    # assign weighted x/y positions
    weights = sqrt((lores - min(lores)) / (max(lores) - min(lores)))
    xy.all = expand.grid(1:nrow(lores), 1:ncol(lores))
    xy.bright = xy.all[sample(1:nrow(xy.all), size=sum(ceiling(dat[,"NUM"])), prob=weights, replace=FALSE),]
    colnames(xy.bright) = c("x","y")
    xy.bright[,1] = xy.bright[,1]*100 + runif(n=nrow(xy.bright), min=-99.5, max=0.5)
    xy.bright[,2] = xy.bright[,2]*100 + runif(n=nrow(xy.bright), min=-99.5, max=0.5)
    out[,"x"] = formatC(xy.bright[,"x"],format="f",digits=1)
    out[,"y"] = formatC(xy.bright[,"y"],format="f",digits=1)
    
    # write
    write.csv(out, file=outname, row.names=FALSE, quote=FALSE)
    
}

# finish up
cat("\n")

