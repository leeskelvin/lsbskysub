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
if(file.exists("cat")){system("rm -R cat")}; system("mkdir cat")
if(file.exists("map")){system("rm -R map")}; system("mkdir map")
if(file.exists("mat")){system("rm -R mat")}; system("mkdir mat")

# software
gzip = "/bin/gzip"
arithmetic = "/usr/local/bin/astarithmetic"
noisechisel = "/usr/local/bin/astnoisechisel" # local noisechisel binary
segment = "/usr/local/bin/astsegment" # local segment binary
mkcatalog = "/usr/local/bin/astmkcatalog" # local mkcatalog binary
unlink(c("temp_modsub.fits", "temp.fits", "temp_detected.fits", "temp_detected_segmented.fits", "temp_detected_segmented_cat.dat"))

# loop
ndets = nmatchs = skymeans = skystds = lumfrac25Alls = lumfrac50Alls = lumfrac75Alls = lumfrac25Bigs = lumfrac50Bigs = lumfrac75Bigs = {}
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
    defmaskzip = paste0("../sex_default/map/", bases[i], ".map.fits.gz")
    defmasktemp = strsplit(defmaskzip, ".gz")[[1]]
    defmaskname = "defmaskfile.fits"
    system(paste(funpack, "-O", modelname, modelzip))
    system(paste0(gzip, " -d -k ", defmaskzip))
    system(paste("mv", defmasktemp, defmaskname))
    modeldat = read.fitsim(modelname)
    maskdat = read.fitsim(defmaskname, hdu=1)
    unlink(modelname)
    scifits = read.fits("temp.fits")
    moddat = scifits$dat[[1]] - (modeldat*1)
    moddat[maskdat>0] = NA
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
    colnames(catdat) = c("OBJ_ID", "X", "Y", "BRIGHTNESS", "MAGNITUDE", "SEMI_MAJOR", "SEMI_MINOR", "GEO_SEMI_MAJOR", "GEO_SEMI_MINOR", "SN", "AXIS_RATIO", "POSITION_ANGLE", "SKY", "STD", "AREA", "UPPERLIMIT")
    segfits = read.fits("temp_detected_segmented.fits", hdu=3+1)
    skyfits = read.fits("temp_detected.fits", hdu=3+1)
    #stdfits = read.fits("temp_detected.fits", hdu=4+1)
    ndets = c(ndets, nrow(catdat))
    spbgdat = regrid(skyfits$dat[[1]][1:4200,26:4075], fact=1/c(30,30)) / (30*30)
    skymeans = c(skymeans, mean(spbgdat))
    skystds = c(skystds, sd(spbgdat))

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
    largesamp = which(matchdat[,"A35_INPUT"] >= sort(matchdat[,"A35_INPUT"],decreasing=TRUE)[25])
    #areafracs = c(areafracs, mean(matchdat[,"AREA_OUTPUT"]/matchdat[,"AREA35_INPUT"]))
    #areafrac5s = c(areafrac5s, mean(matchdat[largesamp,"AREA_OUTPUT"]/matchdat[largesamp,"AREA35_INPUT"]))
    #areameans = c(areameans, mean(matchdat[,"AREA_OUTPUT"]))
    #areamean5s = c(areamean5s, mean(matchdat[largesamp,"AREA_OUTPUT"]))
    luminput = 10^(-0.4*(matchdat[,"MAG_INPUT"] - 27))
    lumoutput = 10^(-0.4*(matchdat[,"MAG_OUTPUT"] - 27))
    lumstatsAll = quantile(lumoutput/luminput, probs=c(0.25,0.5,0.75))
    lumstatsBig = quantile((lumoutput[largesamp])/(luminput[largesamp]), probs=c(0.25,0.5,0.75))
    lumfrac25Alls = c(lumfrac25Alls, as.numeric(lumstatsAll["25%"]))
    lumfrac50Alls = c(lumfrac50Alls, as.numeric(lumstatsAll["50%"]))
    lumfrac75Alls = c(lumfrac75Alls, as.numeric(lumstatsAll["75%"]))
    lumfrac25Bigs = c(lumfrac25Bigs, as.numeric(lumstatsBig["25%"]))
    lumfrac50Bigs = c(lumfrac50Bigs, as.numeric(lumstatsBig["50%"]))
    lumfrac75Bigs = c(lumfrac75Bigs, as.numeric(lumstatsBig["75%"]))

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
    hdr = list(rbind(segfits$hdr[[1]],c("EXTNAME","SEGMAP","")), cbind(key="EXTNAME",value="MAGMAP",comment=""), rbind(skyfits$hdr[[1]],c("EXTNAME","SKYMAP","")))
    dat = list(segfits$dat[[1]], magdat, round(skyfits$dat[[1]],digits=5))
    write.fits(list(hdr=hdr,dat=dat), file=mapname)
    system(paste(gzip, "--best --force", mapname))
    #system(paste(fpack, "-D -Y", mapname))

    # clean up
    unlink(c("temp_modsub.fits", "temp.fits", "temp_detected.fits", "temp_detected_segmented.fits", "temp_detected_segmented_cat.dat", defmaskname))

}

# write stats
temp = cbind(ID=bases, NDET=ndets, NMATCH=nmatchs, SKYMEAN=skymeans, SKYSTD=skystds, LUMFRAC25ALL=lumfrac25Alls, LUMFRAC50ALL=lumfrac50Alls, LUMFRAC75ALL=lumfrac75Alls, LUMFRAC25BIG=lumfrac25Bigs, LUMFRAC50BIG=lumfrac50Bigs, LUMFRAC75BIG=lumfrac75Bigs)
write.csv(temp, file=statsname, row.names=FALSE, quote=FALSE)

# finish up
cat(" 8 / 8\n")

