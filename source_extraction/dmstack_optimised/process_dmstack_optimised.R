#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
incats = grep(".csv", dir("raw", full.names=TRUE), value=TRUE)
if(file.exists("cat")){system("rm -R cat")}; system("mkdir cat")
if(file.exists("map")){system("rm -R map")}; system("mkdir map")
if(file.exists("mat")){system("rm -R mat")}; system("mkdir mat")
statsname = paste0("stats_",basename(getwd()),".csv")
unlink(statsname)

# software
funpack = "/usr/bin/funpack"
fpack = "/usr/bin/fpack"
gzip = "/bin/gzip"

# loop
bases = ndets = nmatchs = skymeans = skystds = lumfrac25Alls = lumfrac50Alls = lumfrac75Alls = lumfrac25Bigs = lumfrac50Bigs = lumfrac75Bigs = {}
for(i in 1:length(incats)){

    # setup
    cat("", i-1, "/", length(incats), "\n")
    if(length(grep("8283-38",incats[i]))>0){base1="denlo"}else{base1="denhi"}
    if(length(grep("n1",incats[i]))>0){base2="1"}else{base2="4"}
    if(length(grep("-a",incats[i]))>0){base3="a"}else{base3="b"}
    base = paste0(base1,base2,base3)
    bases = c(bases, base)
    inback = paste0("raw/bg_", strsplit(strsplit(incats[[i]],"raw/")[[1]][2],".csv")[[1]][1], ".fz")
    indet = paste0("raw/det_", strsplit(strsplit(incats[[i]],"raw/")[[1]][2],".csv")[[1]][1], ".fz")
    catname = paste0("cat/",base,".cat.csv")
    mapname = paste0("map/",base,".map.fits")

    # catalogue data
    catdat = read.csv(incats[i])
    temp = cbind(
        id = catdat[,"id"]
        , x = catdat[,"base_SdssShape_x"]
        , y = catdat[,"base_SdssShape_y"]
        , luminosity_counts = catdat[,"base_SdssShape_instFlux"]
        , xx = catdat[,"base_SdssShape_xx"]
        , yy = catdat[,"base_SdssShape_yy"]
        , xy = catdat[,"base_SdssShape_xy"]
        , area_pixel = catdat[,"base_FootprintArea_value"]
    )
    write.csv(temp, file=catname, row.names=FALSE, quote=FALSE)
    ndets = c(ndets, nrow(catdat))

    # cat matching
    bits = strsplit(strsplit(strsplit(incats[i], "raw/")[[1]][2], ".fits.csv")[[1]], ".simulated")[[1]]
    incat = paste0("../../sims/cat-input/", bits[1], ".cat-input", bits[2], ".dat")
    system(paste("../dmstack_default/do_match.R", incat, catname))
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

    # map data
    system(paste(funpack, "-O temp_bg.fits", inback))
    system(paste(funpack, "-O temp_det.fits", indet))
    bgdat = read.fitsim("temp_bg.fits")
    detdat = read.fitsim("temp_det.fits")
    blank = matrix(0, nrow=nrow(bgdat), ncol=ncol(detdat))
    fitslist = list(dat=list(detdat,blank,round(bgdat,digits=5)), hdr=list(cbind(key="EXTNAME",value="SEGMAP"), cbind(key="EXTNAME",value="MAGMAP"), cbind(key="EXTNAME",value="SKYMAP")))
    write.fits(fitslist, file=mapname)
    system(paste(gzip, "--best --force", mapname))
    #system(paste0(fpack, " -D -Y ", mapname))
    spbgdat = regrid(bgdat[1:4200,26:4075], fact=1/c(30,30)) / (30*30)
    skymeans = c(skymeans, mean(spbgdat))
    skystds = c(skystds, sd(spbgdat))

    # clean up
    unlink(c("temp_bg.fits", "temp_det.fits"))

}

# write stats
temp = cbind(ID=bases, NDET=ndets, NMATCH=nmatchs, SKYMEAN=skymeans, SKYSTD=skystds, LUMFRAC25ALL=lumfrac25Alls, LUMFRAC50ALL=lumfrac50Alls, LUMFRAC75ALL=lumfrac75Alls, LUMFRAC25BIG=lumfrac25Bigs, LUMFRAC50BIG=lumfrac50Bigs, LUMFRAC75BIG=lumfrac75Bigs)
write.csv(temp, file=statsname, row.names=FALSE, quote=FALSE)

# finish up
cat(" 8 / 8\n")

