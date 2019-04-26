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
noisechisel = "/usr/local/bin/astnoisechisel" # local noisechisel binary
segment = "/usr/local/bin/astsegment" # local segment binary
mkcatalog = "/usr/local/bin/astmkcatalog" # local mkcatalog binary
unlink(c("temp.fits","temp_detected.fits","temp_detected_segmented.fits","temp_detected_segmented_cat.dat"))

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
    
    # noisechisel
    system(paste(noisechisel, "-h0 temp.fits"))
    
    # segment
    system(paste(segment, "temp_detected.fits"))
    
    # mkcatalog
    system(paste(mkcatalog, "--config=columns.conf --insky=temp_detected.fits temp_detected_segmented.fits --output=temp_detected_segmented_cat.dat"))
    
    # data read
    catdat = read.table("temp_detected_segmented_cat.dat", stringsAsFactors=FALSE)
    colnames(catdat) = c("OBJ_ID", "BRIGHTNESS", "MAGNITUDE", "MAX_X", "MAX_Y", "SKY", "UPPERLIMIT", "X", "Y", "GEO_SEMI_MAJOR", "GEO_SEMI_MINOR", "POSITION_ANGLE", "AXIS_RATIO", "AREA", "SEMI_MAJOR")
    segfits = read.fits("temp_detected_segmented.fits", hdu=3+1)
    skyfits = read.fits("temp_detected.fits", hdu=3+1)
    stdfits = read.fits("temp_detected.fits", hdu=4+1)
    nobjs = c(nobjs, nrow(catdat))
    skymeans = c(skymeans, mean(skyfits$dat[[1]]))
    skystds = c(skystds, mean(stdfits$dat[[1]]))
    
    # cat processing
    ellipticity = 1 - catdat[,"AXIS_RATIO"]
    catdat[,"AXIS_RATIO"] = ellipticity
    colnames(catdat)[which(colnames(catdat)=="AXIS_RATIO")] = "ELLIPTICITY"
    write.csv(catdat, file=catname, row.names=FALSE, quote=FALSE)
    
    # map processing
    segdat = segfits$dat[[1]]
    magdat = matrix(0, nrow=nrow(segdat), ncol=ncol(segdat))
    magids = round((catdat[,"MAGNITUDE"] + 27),digits=1)
    magmid = sort(unique(magids))
    for(j in 1:length(magmid)){
        segnums = catdat[which(magids == magmid[j]),"OBJ_ID"]
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
    unlink(c("temp.fits","temp_detected.fits","temp_detected_segmented.fits","temp_detected_segmented_cat.dat"))
    
}

# write stats
temp = cbind(ID=bases, NOBJ=nobjs, SKYMEAN=skymeans, SKYSTD=skystds)
write.csv(temp, file=statsname, row.names=FALSE, quote=FALSE)

# finish up
cat(" 8 / 8\n")

