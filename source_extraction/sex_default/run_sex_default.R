#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
denlo1a = "../../sims/simdat/v3/calexp-HSC-R-8283-38.simulated-n1.fits.fz"
denlo1b = "../../sims/simdat/v3/calexp-HSC-R-8283-38.simulated-n1-nofaint.fits.fz"
denlo4a = "../../sims/simdat/v3/calexp-HSC-R-8283-38.simulated-n4.fits.fz"
denlo4b = "../../sims/simdat/v3/calexp-HSC-R-8283-38.simulated-n4-nofaint.fits.fz"
denhi1a = "../../sims/simdat/v3/calexp-HSC-R-9592-20.simulated-n1.fits.fz"
denhi1b = "../../sims/simdat/v3/calexp-HSC-R-9592-20.simulated-n1-nofaint.fits.fz"
denhi4a = "../../sims/simdat/v3/calexp-HSC-R-9592-20.simulated-n4.fits.fz"
denhi4b = "../../sims/simdat/v3/calexp-HSC-R-9592-20.simulated-n4-nofaint.fits.fz"
files = c(denlo1a, denlo1b, denlo4a, denlo4b, denhi1a, denhi1b, denhi4a, denhi4b)
bases = c("denlo1a", "denlo1b", "denlo4a", "denlo4b", "denhi1a", "denhi1b", "denhi4a", "denhi4b")
sex = "/usr/bin/sextractor" # local SEx binary
funpack = "/usr/bin/funpack" # local FITS unpack binary
fpack = "/usr/bin/fpack" # local FITS pack binary

# loop
backs = rmss = threshs = nobjs = {}
for(i in 1:length(files)){
    
    # setup
    cat("", i-1, "/", length(files), "\n")
    segmap = paste0(bases[i], ".segmap.fits")
    magmap = paste0(bases[i], ".magmap.fits")
    
    # unpack
    system(paste(funpack, "-O temp.fits", files[i]))
    
    # source extract
    output = system(paste0(sex, " -c default.sex -CATALOG_NAME ", bases[i], ".dat -CATALOG_TYPE ASCII temp.fits -CHECKIMAGE_TYPE segmentation -CHECKIMAGE_NAME ", segmap, " 2>&1"), intern=T)
    dat = read.table(paste0(bases[i],".dat"), stringsAsFactors=FALSE)
    colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS")
    
    # SEx stats
    obits = strsplit(grep("RMS:", output, value=TRUE), " +")[[1]]
    backs = c(backs, as.numeric(obits[3]))
    rmss = c(rmss, as.numeric(obits[5]))
    threshs = c(threshs, as.numeric(obits[8]))
    nobjs = c(nobjs, nrow(dat))
    
    # magmap
    fits = read.fits(segmap)
    segdat = fits$dat[[1]]
    magdat = matrix(as.integer(0), nrow=nrow(segdat), ncol=ncol(segdat))
    bw = 0.5
    magmids = seq(0.5,30,by=bw)
    magids = round((dat[,"MAG_AUTO"] + 27) * 2)
    for(j in 1:length(magmids)){
        segnums = dat[which(magids == j),"NUMBER"]
        if(length(segnums) > 0){
            pixels = which(segdat %in% segnums)
            magdat[pixels] = as.integer(j)
        }
    }
    fits$dat[[1]] = magdat
    write.fits(fits, file=magmap, type="b")
    system(paste(fpack, "-D -Y", magmap))
    
    # clean up
    unlink(c("temp.fits",segmap))
    
}

# write statistics
temp = cbind(ID=bases, BACK=backs, RMS=rmss, THRESH=threshs, NOBJ=nobjs)
write.csv(temp, file=paste0("stats_",basename(getwd()),".csv"), row.names=FALSE, quote=FALSE)

# finish up
cat(" 8 / 8\n")

