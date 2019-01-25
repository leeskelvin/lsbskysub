#!/usr/bin/Rscript --no-init-file

# definitions
indir = normalizePath("../calexp")
fnames = grep(".fits.fz", dir("../calexp"), value=TRUE)
sex = "/usr/bin/sextractor" # local SEx binary
funpack = "/usr/bin/funpack" # local FITS unpack binary

# loop
for(i in 1:length(fnames)){
    
    ftemp = strsplit(fnames[i], ".fz")[[1]]
    fcat = paste0(strsplit(fnames[i], ".fits.fz")[[1]], ".dat")
    system(paste0(funpack, " -O ", getwd(), "/", ftemp, " ", indir, "/", fnames[i]))
    system(paste0(sex, " -c default.sex -CATALOG_NAME ", fcat, " -CATALOG_TYPE ASCII -CHECKIMAGE_TYPE SEGMENTATION -CHECKIMAGE_NAME test.fits ", ftemp))
    unlink(ftemp)
    
}

