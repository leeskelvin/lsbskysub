#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
set.seed(5)

# definitions
cats = paste0("../../hsc_data/calexp/", grep(".dat", dir("../../hsc_data/calexp/"), value=TRUE))
pixelsize = 0.168 # arcsec/pixel
n = 1 # sersic index

# loop
for(i in 1:length(cats)){
    
    # setup
    dat = read.table(cats[i], stringsAsFactors=FALSE)
    colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS")
    if(any(dat[,"FLUX_AUTO"] < 0)){dat = dat[-dat[,"FLUX_AUTO"]<0,]}
    
    # trim bright sources
    magbright = 22
    bw = 0.5
    toobright = which( (dat[,"MAG_AUTO"]+27) <= (magbright+bw/2) )
    dat = dat[-toobright,]
    
    # generate GalSim input catalogue: x, y, flux, half_light_radius, q, theta, n, stamp_size
    out = data.frame(x=dat[,"X_IMAGE"], y=dat[,"Y_IMAGE"], flux=dat[,"FLUX_AUTO"], half_light_radius=dat[,"FLUX_RADIUS"]*pixelsize, q=1-dat[,"ELLIPTICITY"], theta=dat[,"THETA_IMAGE"], n=rep(n, nrow(dat)))
    stamp_size = ceiling(2*sersic.fluxfrac2r(0.999, n=n, r.ref=out[,"half_light_radius"]/pixelsize, fluxfrac.ref=0.5)) # pixels
    out = cbind(out, stamp_size=stamp_size)
    
    # write
    outname = paste0(strsplit(basename(cats[i]), ".image.dat")[[1]], ".cat-detused-n",n,".dat")
    write.table(out, file=outname, sep=" ", row.names=FALSE, quote=FALSE, col.names=FALSE)
    
}

# screen output
cat("\n")
print(data.frame(COLUMN=1:ncol(out)-1, NAME=colnames(out)), row.names=rep("",8))
cat("\n")

