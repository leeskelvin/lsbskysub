#!/usr/bin/Rscript --no-init-file

# setup
#require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
brights = paste0("../cat-bright/", grep(".cat-", dir("../cat-bright"), value=TRUE))
detuseds = paste0("../cat-detused/", grep(".cat-", dir("../cat-detused"), value=TRUE))
faints = paste0("../cat-faint/", grep(".cat-", dir("../cat-faint"), value=TRUE))

# loop
for(i in 1:length(brights)){
    
    bdat = read.table(brights[i])
    ddat = read.table(detuseds[i])
    fdat = read.table(faints[i])
    
    out = rbind(bdat, ddat, fdat)
    
    outname = paste(strsplit(basename(brights[i]), ".cat-bright")[[1]], collapse=".cat-final")
    write.table(out, file=outname, sep=" ", row.names=FALSE, quote=FALSE, col.names=FALSE)
    
}

