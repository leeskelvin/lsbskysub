#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
set.seed(5)

# definitions
cats = paste0("../../hsc_data/numcounts/", grep(".csv", dir("../../hsc_data/numcounts/"), value=TRUE))
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
    out = data.frame(x=numeric(nrow(dat)), y=numeric(nrow(dat)), flux=numeric(nrow(dat)), half_light_radius=numeric(nrow(dat)), q=numeric(nrow(dat)), theta=numeric(nrow(dat)), n=n, stamp_size=numeric(nrow(dat)))
    
    # loop
    for(j in 1:nrow(dat)){
        
        # setup
        num = ceiling(dat[j,"NUM"])
        mags = dat[j,"MAG"] + runif(num, min=-bw/2, max=bw/2) # r-band
        flux = 10^(-0.4 * (mags - 27)) # counts
        ## needs 25% spread ## half_light_radius = (-0.15 * mags) + 4.25 # arcsec
        
        
    }
    
    
    
    out = data.frame(x=dat[,"X_IMAGE"], y=dat[,"Y_IMAGE"], flux=dat[,"FLUX_AUTO"], half_light_radius=dat[,"FLUX_RADIUS"]*pixelsize, q=1-dat[,"ELLIPTICITY"], theta=dat[,"THETA_IMAGE"], n=rep(n, nrow(dat)))
    stamp_size = ceiling(2*sersic.fluxfrac2r(0.999, n=n, r.ref=out[,"half_light_radius"]/pixelsize, fluxfrac.ref=0.5)) # pixels
    out = cbind(out, stamp_size=stamp_size)
    
    
    
    
    
    # derive new mock bright sources
    bdat = dat[which(dat[,"MAG"] <= magbright),]
    bdat = bdat[-which(bdat[,"NUM"]==0),]
    bgalmags = rep(bdat[,"MAG"], times=ceiling(bdat[,"NUM"])) + runif(sum(ceiling(bdat[,"NUM"])), min=-bw/2, max=bw/2)
    file.regrid = paste0("../regrid/", strsplit(basename(datas[i]), ".image.dat")[[1]], ".regrid.fits")
    imdat.regrid = read.fitsim(file.regrid)
    imdat.probs = sqrt((imdat.regrid - min(imdat.regrid)) / (max(imdat.regrid) - min(imdat.regrid)))
    xy.all = expand.grid(1:nrow(imdat.regrid), 1:ncol(imdat.regrid))
    xy.bright = xy.all[sample(1:nrow(xy.all), size=sum(ceiling(bdat[,"NUM"])), prob=imdat.probs),]
    colnames(xy.bright) = c("x","y")
    xy.bright[,1] = xy.bright[,1]*100 + runif(n=nrow(xy.bright), min=-100, max=0)
    xy.bright[,2] = xy.bright[,2]*100 + runif(n=nrow(xy.bright), min=-100, max=0)
    out.bright = data.frame(x=xy.bright[,"x"], y=xy.bright[,"y"], flux=10^(-0.4*(bgalmags-27)), half_light_radius=5, q=1, theta=0, n=n)
    
    # generate GalSim input catalogue: n, half_light_radius, flux, q, theta, stamp_size, x, y
    out.dat = data.frame(x=dat[,"X_IMAGE"], y=dat[,"Y_IMAGE"], flux=dat[,"FLUX_AUTO"], half_light_radius=dat[,"FLUX_RADIUS"]*pixelsize, q=1-dat[,"ELLIPTICITY"], theta=dat[,"THETA_IMAGE"], n=rep(n, nrow(dat)))
    
    # bright/faint additions here
    
    
    # write
    out = rbind(out.dat, out.bright)
    stamp_size = ceiling(2*sersic.fluxfrac2r(0.999, n=n, r.ref=out[,"half_light_radius"]/pixelsize, fluxfrac.ref=0.5)) # pixels
    out = cbind(out, stamp_size=stamp_size)
    outname = paste0(strsplit(basename(datas[i]), ".image.dat")[[1]], ".input.dat")
    write.table(out, file=outname, sep=" ", row.names=FALSE, quote=FALSE, col.names=FALSE)
    
}

# screen output
cat("\n")
print(data.frame(COLUMN=1:ncol(out)-1, NAME=colnames(out)), row.names=rep("",8))
cat("\n")

