#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
incats = grep(".csv", dir("raw", full.names=TRUE), value=TRUE)
if(!file.exists("cat")){system("mkdir cat")}
if(!file.exists("map")){system("mkdir map")}
if(!file.exists("mat")){system("mkdir mat")}
statsname = paste0("stats_",basename(getwd()),".csv")
unlink(statsname)

# software
funpack = "/usr/bin/funpack"
fpack = "/usr/bin/fpack"
gzip = "/bin/gzip"

# loop
bases = ndets = nmatchs = areafracs = areameans = areafrac5s = areamean5s = skymeans = skystds = {}
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
    areafracs = c(areafracs, mean(matchdat[,"AREA_OUTPUT"]/matchdat[,"AREA35_INPUT"]))
    large5samp = which(matchdat[,"A35_INPUT"] >= sort(matchdat[,"A35_INPUT"],decreasing=TRUE)[5])
    areafrac5s = c(areafrac5s, mean(matchdat[large5samp,"AREA_OUTPUT"]/matchdat[large5samp,"AREA35_INPUT"]))
    areameans = c(areameans, mean(matchdat[,"AREA_OUTPUT"]))
    areamean5s = c(areamean5s, mean(matchdat[large5samp,"AREA_OUTPUT"]))
    
    # map data
    system(paste(funpack, "-O temp_bg.fits", inback))
    system(paste(funpack, "-O temp_det.fits", indet))
    bgdat = read.fitsim("temp_bg.fits")
    detdat = read.fitsim("temp_det.fits")
    blank = matrix(0, nrow=nrow(bgdat), ncol=ncol(detdat))
    write.fits(list(detdat,blank,bgdat,blank), file=mapname)
    system(paste0(fpack, " -D -Y ", mapname))
    skymeans = c(skymeans, mean(bgdat))
    skystds = c(skystds, NA)
    
    # clean up
    unlink(c("temp_bg.fits", "temp_det.fits"))
    
}

# write stats
temp = cbind(ID=bases, NDET=ndets, NMATCH=nmatchs, AREAFRAC=areafracs, AREAMEAN=areameans, AREAFRAC5=areafrac5s, AREAMEAN5=areamean5s, SKYMEAN=skymeans, SKYSTD=skystds)
write.csv(temp, file=statsname, row.names=FALSE, quote=FALSE)

# finish up
cat(" 8 / 8\n")

