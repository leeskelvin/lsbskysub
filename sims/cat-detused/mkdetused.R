#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
set.seed(5)

# definitions
cats = paste0("../../hsc_data/calexp/", grep(".dat", dir("../../hsc_data/calexp/"), value=TRUE))
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
    dat = read.table(cats[i], stringsAsFactors=FALSE)
    colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS")
    if(any(dat[,"FLUX_AUTO"] < 0)){dat = dat[-dat[,"FLUX_AUTO"]<0,]}
    
    # trim bright sources
    magbright = 22
    bw = 0.5
    toobright = which( (dat[,"MAG_AUTO"]+27) <= (magbright+bw/2) )
    dat = dat[-toobright,]
    
    # generate GalSim input catalogue: x, y, flux, half_light_radius, q, theta, n, stamp_size
    # digits: x=1, y=1, flux=3, half_light_radius=3, q=2, theta=1, n=NA, stamp_size=NA
    out = data.frame(x=formatC(dat[,"X_IMAGE"],format="f",digits=1), y=formatC(dat[,"Y_IMAGE"],format="f",digits=1), flux=formatC(dat[,"FLUX_AUTO"],format="f",digits=3), half_light_radius=formatC(dat[,"FLUX_RADIUS"]*pixelsize,format="f",digits=3), q=formatC(1-dat[,"ELLIPTICITY"],format="f",digits=2), theta=formatC(dat[,"THETA_IMAGE"],format="f",digits=1), n=rep(n, nrow(dat)), stringsAsFactors=FALSE)
    #stamp_size = ceiling(2*sersic.fluxfrac2r(fluxfrac, n=n, r.ref=as.numeric(out[,"half_light_radius"])/pixelsize, fluxfrac.ref=0.5)) + stampextra # pixels
    stamp_size = 1 + stampextra + 2*ceiling(sersic.mu2r(mu=mulim, mag=dat[,"MAG_AUTO"]+27, n=n, re=dat[,"FLUX_RADIUS"], e=dat[,"ELLIPTICITY"])) # pixels
    if(any(stamp_size < stampmin)){stamp_size[stamp_size<stampmin] = stampmin}
    out = cbind(out, stamp_size=stamp_size)
    
    # write
    outname = paste0(strsplit(basename(cats[i]), ".image.dat")[[1]], ".cat-detused-n",n,".dat")
    write.table(out, file=outname, sep=" ", row.names=FALSE, quote=FALSE, col.names=FALSE)
    
}

# screen output
cat("\n")
print(data.frame(COLUMN=1:ncol(out)-1, NAME=colnames(out)), row.names=rep("",8))
cat("\n")

