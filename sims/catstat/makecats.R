#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
set.seed(5)

# definitions
datas = paste0("../../hsc_data/calexp/", grep(".dat", dir("../../hsc_data/calexp/"), value=TRUE))
extras = paste0("../../hsc_data/numcounts/", grep(".csv", dir("../../hsc_data/numcounts/"), value=TRUE))
pixelsize = 0.168 # arcsec/pixel

# loop
for(i in 1:length(datas)){
    
    # setup
    dat = read.table(datas[i], stringsAsFactors=FALSE)
    colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS")
    if(any(dat[,"FLUX_AUTO"] < 0)){dat = dat[-dat[,"FLUX_AUTO"]<0,]}
    ext = read.csv(extras[i], stringsAsFactors=FALSE)
    
    # trim bright sources
    magbright = 22
    magfaint = 25
    magend = 30
    bw = 0.5
    toobright = which( (dat[,"MAG_AUTO"]+27) <= (magbright+bw/2) )
    dat = dat[-toobright,]
    
    # derive new mock bright sources
    bdat = ext[which(ext[,"MAG"] <= magbright),]
    bdat = bdat[-which(bdat[,"NUM"]==0),]
    bgalmags = rep(bdat[,"MAG"], times=ceiling(bdat[,"NUM"])) + runif(sum(ceiling(bdat[,"NUM"])), min=-bw/2, max=bw/2)
    file.regrid = paste0("../regrid/", strsplit(basename(datas[i]), ".image.dat")[[1]], ".regrid.fits")
    imdat.regrid = read.fitsim(file.regrid)
    imdat.probs = (imdat.regrid - min(imdat.regrid)) / (max(imdat.regrid) - min(imdat.regrid))
    imdat.probs = (imdat.probs * 0.5) + 0.5 # p = 0.5-1.0
    xy = expand.grid(1:nrow(imdat.regrid), 1:ncol(imdat.regrid))
    xy.selected = xy[sample(1:length(imdat.regrid), size=sum(ceiling(bdat[,"NUM"])), prob=imdat.probs),]
    
    
    
    
    limit.regrid = sort(imdat.regrid, decreasing=T)[sum(ceiling(bdat[,"NUM"]))]
    xy.regrid = which(imdat.regrid >= limit.regrid, arr.ind=T)
    for(j in 1:nrow(bdat)){
        
    }
    
    # derived/assigned quantities
    n = rep(1, nrow(dat))
    stamp_size = ceiling(2*sersic.fluxfrac2r(0.999, n=n, r.ref=dat[,"FLUX_RADIUS"], fluxfrac.ref=0.5)) # pixels
    
    # generate GalSim input catalogue: n, half_light_radius, flux, q, theta, stamp_size, x, y
    out = data.frame(x=dat[,"X_IMAGE"], y=dat[,"Y_IMAGE"], flux=dat[,"FLUX_AUTO"], half_light_radius=dat[,"FLUX_RADIUS"]*pixelsize, q=1-dat[,"ELLIPTICITY"], theta=dat[,"THETA_IMAGE"], n=n, stamp_size=stamp_size)
    
    # bright/faint additions here
    
    
    # write
    outname = paste0(strsplit(basename(datas[i]), ".image.dat")[[1]], ".input.dat")
    write.table(out, file=outname, sep=" ", row.names=FALSE, quote=FALSE, col.names=FALSE)
    
}

# screen output
cat("\n")
print(data.frame(COLUMN=1:ncol(out)-1, NAME=colnames(out)), row.names=rep("",8))
cat("\n")

