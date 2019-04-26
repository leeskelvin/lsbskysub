#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
denlo1a = "../../sims/simdat/v5/calexp-HSC-R-8283-38.simulated-n1-a.fits.fz"
denlo1b = "../../sims/simdat/v5/calexp-HSC-R-8283-38.simulated-n1-b.fits.fz"
denlo4a = "../../sims/simdat/v5/calexp-HSC-R-8283-38.simulated-n4-a.fits.fz"
denlo4b = "../../sims/simdat/v5/calexp-HSC-R-8283-38.simulated-n4-b.fits.fz"
denhi1a = "../../sims/simdat/v5/calexp-HSC-R-9592-20.simulated-n1-a.fits.fz"
denhi1b = "../../sims/simdat/v5/calexp-HSC-R-9592-20.simulated-n1-b.fits.fz"
denhi4a = "../../sims/simdat/v5/calexp-HSC-R-9592-20.simulated-n4-a.fits.fz"
denhi4b = "../../sims/simdat/v5/calexp-HSC-R-9592-20.simulated-n4-b.fits.fz"
files = c(denlo1a, denlo1b, denlo4a, denlo4b, denhi1a, denhi1b, denhi4a, denhi4b)
bases = c("denlo1a", "denlo1b", "denlo4a", "denlo4b", "denhi1a", "denhi1b", "denhi4a", "denhi4b")
funpack = "/usr/bin/funpack" # local FITS unpack binary
fpack = "/usr/bin/fpack" # local FITS pack binary
gzip = "/bin/gzip" # local gzip binary
statsname = paste0("stats_",basename(getwd()),".csv")
unlink(statsname)
if(!file.exists("cat")){system("mkdir cat")}
if(!file.exists("map")){system("mkdir map")}

# detection software
sex = "/usr/bin/sextractor" # local SEx binary
unlink(c("temp.fits","temp_cat.dat", "temp_seg.fits", "temp_sky.fits", "temp_std.fits"))

# loop
nobjs = skymeans = skystds = {}
for(i in 1:length(files)){
    
    # setup
    cat("", i-1, "/", length(files), "\n")
    catname = paste0("cat/", bases[i], ".cat.csv")
    mapname = paste0("map/", bases[i], ".map.fits")
    unlink(c(catname,mapname,paste0(mapname,".fz"),paste0(mapname,".gz")))
    
    # unpack
    system(paste(funpack, "-O temp.fits", files[i]))
    
    # source extract
    output = system(paste0(sex, " -c default.sex -CATALOG_NAME temp_cat.dat -CATALOG_TYPE ASCII -CHECKIMAGE_TYPE SEGMENTATION,BACKGROUND,BACKGROUND_RMS -CHECKIMAGE_NAME temp_seg.fits,temp_sky.fits,temp_std.fits temp.fits 2>&1"), intern=T)
    
    # data read
    catdat = read.table("temp_cat.dat", stringsAsFactors=FALSE)
    colnames(catdat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "THRESHOLD", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS")
    segfits = read.fits("temp_seg.fits")
    skyfits = read.fits("temp_sky.fits")
    stdfits = read.fits("temp_std.fits")
    nobjs = c(nobjs, nrow(catdat))
    skymeans = c(skymeans, mean(skyfits$dat[[1]]))
    skystds = c(skystds, mean(stdfits$dat[[1]]))
    
    # cat processing
    write.csv(catdat, file=catname, row.names=FALSE, quote=FALSE)
    
    # map processing
    segdat = segfits$dat[[1]]
    magdat = matrix(0, nrow=nrow(segdat), ncol=ncol(segdat))
    magids = round((catdat[,"MAG_AUTO"] + 27),digits=1)
    magmid = sort(unique(magids))
    for(j in 1:length(magmid)){
        segnums = catdat[which(magids == magmid[j]),"NUMBER"]
        if(length(segnums) > 0){
            pixels = which(segdat %in% segnums)
            magdat[pixels] = magmid[j]
        }
    }
    hdr = list(segfits$hdr[[1]], NA, skyfits$hdr[[1]], stdfits$hdr[[1]])
    dat = list(segfits$dat[[1]], magdat, round(skyfits$dat[[1]],digits=5), round(stdfits$dat[[1]],digits=5))
    write.fits(list(hdr=hdr,dat=dat), file=mapname)
    system(paste(gzip, "--best --force", mapname))
    #system(paste(fpack, "-D -Y", mapname))
    
    # clean up
    unlink(c("temp.fits","temp_cat.dat", "temp_seg.fits", "temp_sky.fits", "temp_std.fits"))
    
}

# write stats
temp = cbind(ID=bases, NOBJ=nobjs, SKYMEAN=skymeans, SKYSTD=skystds)
write.csv(temp, file=statsname, row.names=FALSE, quote=FALSE)

# finish up
cat(" 8 / 8\n")

