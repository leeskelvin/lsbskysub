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
if(!file.exists("mat")){system("mkdir mat")}
if(!file.exists("map")){system("mkdir map")}

# software
gzip = "/bin/gzip"
arithmetic = "/usr/local/bin/astarithmetic"
noisechisel = "/usr/local/bin/astnoisechisel" # local noisechisel binary
segment = "/usr/local/bin/astsegment" # local segment binary
mkcatalog = "/usr/local/bin/astmkcatalog" # local mkcatalog binary
unlink(c("temp_modsub.fits", "temp.fits", "temp_detected.fits", "temp_detected_segmented.fits", "temp_detected_segmented_cat.dat"))

# loop
ndets = nmatchs = areafracs = areameans = areafrac5s = areamean5s = skymeans = skystds = skysprs = medmagdiffs = medmagdiff5s = {}
for(i in 1:length(files)){
    
    # setup
    cat("", i-1, "/", length(files), "\n")
    catname = paste0("cat/", bases[i], ".cat.csv")
    mapname = paste0("map/", bases[i], ".map.fits")
    unlink(c(catname,mapname,paste0(mapname,".fz"),paste0(mapname,".gz")))
    
    # unpack
    system(paste(funpack, "-O temp.fits", files[i]))
    
    # model manipulation
    modelzip = paste0("model/", bases[i], ".model1.fits.fz")
    modelname = paste0("model/", bases[i], ".model1.fits")
    system(paste(funpack, "-O", modelname, modelzip))
    modeldat = read.fitsim(modelname)
    unlink(modelname)
    scifits = read.fits("temp.fits")
    moddat = scifits$dat[[1]] - (modeldat*1)
    write.fits(moddat, file="temp_modsub.fits")
    
    # model processing
    system(paste(noisechisel, "-h0 temp_modsub.fits --ignoreblankintiles"))
    
    # model sky subtraction
    scifits = read.fits("temp.fits")
    detfits = read.fits("temp_modsub_detected.fits")
    write.fits(scifits$dat[[1]] - detfits$dat[[3+1]], file="temp_skysub.fits")
    system(paste(noisechisel, "-h0 temp_skysub.fits"))
    modfits = read.fits("temp_skysub_detected.fits")
    #dets = pmin(pmin(detfits$dat[[2+1]],1) + pmin(modfits$dat[[2+1]],1),1)
    dets = pmin(modfits$dat[[2+1]],1)
    storage.mode(dets) = "integer"
    detfits$dat[[1+1]] = scifits$dat[[1]] - detfits$dat[[3+1]]
    detfits$dat[[2+1]] = dets
    write.fits(detfits, file="temp_detected.fits")
    unlink(c("temp_modsub.fits", "temp_modsub_detected.fits", "temp_skysub.fits", "temp_skysub_detected.fits"))
    
    # segment
    system(paste(segment, "temp_detected.fits"))
    
    # mkcatalog
    system(paste(mkcatalog, "--config=../gnuastro_default/columns.conf --insky=temp_detected.fits temp_detected_segmented.fits --output=temp_detected_segmented_cat.dat"))
    
    # data read
    catdat = read.table("temp_detected_segmented_cat.dat", stringsAsFactors=FALSE)
    colnames(catdat) = c("OBJ_ID", "X", "Y", "BRIGHTNESS", "MAGNITUDE", "SEMI_MAJOR", "SEMI_MINOR", "MAX_X", "MAX_Y", "SN", "AXIS_RATIO", "POSITION_ANGLE", "SKY", "STD", "AREA", "UPPERLIMIT")
    segfits = read.fits("temp_detected_segmented.fits", hdu=3+1)
    skyfits = read.fits("temp_detected.fits", hdu=3+1)
    stdfits = read.fits("temp_detected.fits", hdu=4+1)
    ndets = c(ndets, nrow(catdat))
    skymeans = c(skymeans, mean(skyfits$dat[[1]]))
    skystds = c(skystds, mean(stdfits$dat[[1]]))
    spbgdat = regrid(skyfits$dat[[1]], f=c(2/4200,2/4100))/(2100*2050)
    skysprs = c(skysprs, diff(range(spbgdat)))
    
    # cat processing
    ellipticity = 1 - catdat[,"AXIS_RATIO"]
    catdat[,"AXIS_RATIO"] = ellipticity
    colnames(catdat)[which(colnames(catdat)=="AXIS_RATIO")] = "ELLIPTICITY"
    catdat[,"MAGNITUDE"] = catdat[,"MAGNITUDE"] + 27
    write.csv(catdat, file=catname, row.names=FALSE, quote=FALSE)
    
    # cat matching
    incat = paste0("../../sims/cat-input/", paste0(strsplit(strsplit(basename(files[i]), ".fits.fz")[[1]], "simulated")[[1]], collapse="cat-input"), ".dat")
    system(paste("../gnuastro_default/do_match.R", incat, catname))
    matchdat = read.csv(paste0("mat/",paste0(strsplit(basename(catname), "cat")[[1]], collapse="mat")))
    nmatchs = c(nmatchs, nrow(matchdat))
    areafracs = c(areafracs, mean(matchdat[,"AREA_OUTPUT"]/matchdat[,"AREA35_INPUT"]))
    large5samp = which(matchdat[,"A35_INPUT"] >= sort(matchdat[,"A35_INPUT"],decreasing=TRUE)[5])
    areafrac5s = c(areafrac5s, mean(matchdat[large5samp,"AREA_OUTPUT"]/matchdat[large5samp,"AREA35_INPUT"]))
    areameans = c(areameans, mean(matchdat[,"AREA_OUTPUT"]))
    areamean5s = c(areamean5s, mean(matchdat[large5samp,"AREA_OUTPUT"]))
    medmagdiffs = c(medmagdiffs, median(matchdat[,"MAG_OUTPUT"] - matchdat[,"MAG_INPUT"]))
    medmagdiff5s = c(medmagdiff5s, median(matchdat[large5samp,"MAG_OUTPUT"] - matchdat[large5samp,"MAG_INPUT"]))
    
    # map processing
    segdat = segfits$dat[[1]]
    magdat = matrix(0, nrow=nrow(segdat), ncol=ncol(segdat))
    magids = round((catdat[,"MAGNITUDE"]),digits=1)
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
    unlink(c("temp_modsub.fits", "temp.fits", "temp_detected.fits", "temp_detected_segmented.fits", "temp_detected_segmented_cat.dat"))
    
}

# write stats
temp = cbind(ID=bases, NDET=ndets, NMATCH=nmatchs, AREAFRAC=areafracs, AREAMEAN=areameans, AREAFRAC5=areafrac5s, AREAMEAN5=areamean5s, SKYMEAN=skymeans, SKYSTD=skystds, SKYSPR=skysprs, MEDMAGDIFF=medmagdiffs, MEDMAGDIFF5=medmagdiff5s)
write.csv(temp, file=statsname, row.names=FALSE, quote=FALSE)

# finish up
cat(" 8 / 8\n")

