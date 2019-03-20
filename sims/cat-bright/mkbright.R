#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
set.seed(5)

# definitions
cats = paste0("../../hsc_data/numcounts/", grep(".csv", dir("../../hsc_data/numcounts/"), value=TRUE))
ells = read.csv("../../hsc_data/magellip/magellip.csv")
ells = cbind(ells, ELLID=ells[,"MAG"]+ells[,"QRAD"]/10)
pixelsize = 0.168 # arcsec/pixel
n = 1 # sersic index

# loop
for(i in 1:length(cats)){
    
    # setup
    dat = read.csv(cats[i], stringsAsFactors=FALSE)
    lores = read.fitsim(paste0(strsplit(basename(cats[i]), ".extra.csv")[[1]], ".lores.fits"))
    
    # define bright sources and output results data frame
    magbright = 22
    bw = 0.5
    dat = dat[dat[,"NUM"]>0 & dat[,"MAG"]<=(magbright+bw/2),]
    out = {}
    
    # loop
    for(j in 1:nrow(dat)){
        
        # setup
        binnum = ceiling(dat[j,"NUM"])
        mags = dat[j,"MAG"] + runif(binnum, min=-bw/2, max=bw/2) # r-band
        flux = 10^(-0.4 * (mags - 27)) # counts
        hlrbase = (-0.15 * mags) + 4.25
        hlrzone = runif(binnum, min=-0.25, max=0.25)
        hlrquan = pmin(floor((hlrzone+0.25)*8),3)+1
        half_light_radius = hlrbase + (hlrzone*hlrbase) # arcsec
        ellid = dat[j,"MAG"]+hlrquan/10
        ellip = pmin(pmax(ells[match(ellid, ells[,"ELLID"]),"ELLIP"] + runif(binnum,min=-0.2,max=0.2), 0), 1)
        q = 1 - ellip # axis ratio
        theta = runif(binnum, min=-90, max=90) # degrees
        stamp_size = ceiling(2*sersic.fluxfrac2r(0.999, n=n, r.ref=half_light_radius/pixelsize, fluxfrac.ref=0.5)) # pixels
        out = rbind(out, cbind(x=NA, y=NA, flux=flux, half_light_radius=half_light_radius, q=q, theta=theta, n=n, stamp_size=stamp_size))
        
    }
    
    # assign weighted x/y positions
    weights = sqrt((lores - min(lores)) / (max(lores) - min(lores)))
    xy.all = expand.grid(1:nrow(lores), 1:ncol(lores))
    xy.bright = xy.all[sample(1:nrow(xy.all), size=sum(ceiling(dat[,"NUM"])), prob=weights, replace=FALSE),]
    colnames(xy.bright) = c("x","y")
    xy.bright[,1] = xy.bright[,1]*100 + runif(n=nrow(xy.bright), min=-99, max=0)
    xy.bright[,2] = xy.bright[,2]*100 + runif(n=nrow(xy.bright), min=-99, max=0)
    out[,"x"] = xy.bright[,"x"]
    out[,"y"] = xy.bright[,"y"]
    
    # write
    outname = paste0(strsplit(basename(cats[i]), ".extra.csv")[[1]], ".cat-bright-n",n,".dat")
    write.table(out, file=outname, sep=" ", row.names=FALSE, quote=FALSE, col.names=FALSE)
    
}

# screen output
cat("\n")
print(data.frame(COLUMN=1:ncol(out)-1, NAME=colnames(out)), row.names=rep("",8))
cat("\n")

