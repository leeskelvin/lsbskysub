#!/usr/bin/Rscript --no-init-file

# definitions
indir = normalizePath("../calexp")
fnames = grep(".fits.fz", dir("../calexp"), value=TRUE)
sex = "/usr/bin/sextractor" # local SEx binary
funpack = "/usr/bin/funpack" # local FITS unpack binary
imarith = "~/software/cexamples/imarith" # imarith
astconvertt = "/usr/local/bin/astconvertt" # GNU astro ConvertType
astarithmetic = "/usr/local/bin/astarithmetic" # GNU astro arithmetic
convert = "/usr/bin/convert" # imagemagick convert

# loop
for(i in 1:length(fnames)){
    
    #cat("\b\b\b\b\b     \b\b\b\b\b", i, " ", sep="", collapse="")
    cat("#####\n ",i,"\n#####\n", sep="", collapse="")
    
    # Source Extractor
    fproc = strsplit(fnames[i], ".fz")[[1]]
    fcat = paste0(strsplit(fnames[i], ".fits.fz")[[1]], ".dat")
    fcheck = paste0(strsplit(fnames[i], ".fits.fz")[[1]], ".check.fits")
    system(paste0(funpack, " -O ", getwd(), "/", fproc, " ", indir, "/", fnames[i]))
    system(paste0(sex, " -c default.sex -CATALOG_NAME ", fcat, " -CATALOG_TYPE ASCII -CHECKIMAGE_TYPE SEGMENTATION -CHECKIMAGE_NAME ", fcheck, " ", fproc))
    
    # JPEG check image
    fbinary = paste0(strsplit(fnames[i], ".fits.fz")[[1]], ".binary.fits")
    fmodulo = paste0(strsplit(fnames[i], ".fits.fz")[[1]], ".modulo.fits")
    fmodify = paste0(strsplit(fnames[i], ".fits.fz")[[1]], ".modify.fits")
    jtemp = paste0(strsplit(fnames[i], ".fits.fz")[[1]], ".temp.jpeg")
    pimage = paste0(strsplit(fnames[i], ".fits.fz")[[1]], ".png")
    system(paste0(imarith, " ", fcheck, " ", fcheck, " d ", fbinary))
    system(paste0(astarithmetic, " -h0 ", fcheck, " 10 % --out ", fmodulo))
    system(paste0(imarith, " ", fmodulo, "[1] ", fbinary, " a ", fmodify))
    system(paste0(astconvertt, " -h0 ", fmodify, " --out=", jtemp, " --invert"))
    system(paste0(convert, " ", jtemp, " ", pimage))
    #convert xc:white xc:red xc:orange xc:yellow xc:green xc:blue xc:blueviolet +append -filter Cubic -resize 600x30! -flop cmap.jpeg
    
    # clean up
    unlink(c(fproc,fcheck,fbinary,fmodulo,fmodify,jtemp))
    
}

