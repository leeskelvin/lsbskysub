#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
set.seed(5)

# definitions
n = as.numeric(commandArgs(TRUE)); if(length(n) == 0){stop("specify n")}
cats = paste0("../../hsc_data/calexp/", grep(".dat", dir("../../hsc_data/calexp/"), value=TRUE))
pixelsize = 0.168 # arcsec/pixel

# loop
for(i in 1:length(cats)){
    
    # setup
    dat = read.table(cats[i], stringsAsFactors=FALSE)
    colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS")
    if(any(dat[,"FLUX_AUTO"] < 0)){dat = dat[-dat[,"FLUX_AUTO"]<0,]}
    outname = paste0(strsplit(basename(cats[i]), ".image.dat")[[1]], ".cat-detused-n",n,".csv")
    
    # trim bright sources
    magbright = 22
    bw = 0.5
    toobright = which( (dat[,"MAG_AUTO"]+27) <= (magbright+bw/2) )
    dat = dat[-toobright,]
    
    # output catalogue
    # digits: x=1, y=1, luminosity_counts=5, hlr_pixels=3, q=2, theta=1, n=NA
    out = cbind(
        x = formatC(dat[,"X_IMAGE"],format="f",digits=1)
        , y = formatC(dat[,"Y_IMAGE"],format="f",digits=1)
        , luminosity_counts = formatC(dat[,"FLUX_AUTO"],format="f",digits=5)
        , hlr_pixel = formatC(dat[,"FLUX_RADIUS"],format="f",digits=3)
        , q = formatC(1-dat[,"ELLIPTICITY"],format="f",digits=2)
        , theta = formatC(dat[,"THETA_IMAGE"],format="f",digits=1)
        , n = n
    )
    
    # write
    write.csv(out, file=outname, row.names=FALSE, quote=FALSE)
    
}

# finish up
cat("\n")

