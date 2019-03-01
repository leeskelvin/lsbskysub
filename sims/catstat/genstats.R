#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)

# definitions
manifest = readRDS("../hsc_data/manifest_HSC.rds")
datas = paste0("../hsc_data/calexp/", grep(".dat", dir("../hsc_data/calexp/"), value=TRUE))
imstats = read.csv("../hsc_data/sourcecats/imstats.csv", stringsAsFactors=FALSE)

# loop
for(i in 1:length(datas)){
    
    # setup
    imname = paste0(strsplit(basename(datas[i]), ".dat")[[1]], ".fits")
    manrow = which(basename(manifest[,"SCI"]) == imname)
    imstatsrow = which(imstats[,"FILE"] == paste0(imname,".fz"))
    
    # stats
    gain = manifest[manrow,"GAIN"] # e'/ADU
    xsize = manifest[manrow,"XDIMPIX"]
    ysize = manifest[manrow,"YDIMPIX"]
    rms = imstats[imstatsrow,"RMS"] # ADU
    sky_level_pixel = rms^2 * gain
    
    # write
    out = data.frame(GAIN=gain, XSIZE=xsize, YSIZE=ysize, RMS=rms, SKY_LEVEL_PIXEL=sky_level_pixel)
    write.csv(out, file=paste0(strsplit(basename(datas[i]), ".image.dat")[[1]], ".stats.csv"), row.names=FALSE, quote=FALSE)
    
    # print
    cat("\n")
    tout = t(out); colnames(tout)=basename(datas[i])
    print(tout)
    cat("\n")
    
}

