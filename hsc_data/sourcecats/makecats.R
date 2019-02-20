#!/usr/bin/Rscript --no-init-file

# definitions
#indir = normalizePath("../calexp")
indir = normalizePath("~/Desktop/calexp")
fnames = grep(".fits.fz", dir(indir), value=TRUE)
sex = "/usr/bin/sextractor" # local SEx binary
funpack = "/usr/bin/funpack" # local FITS unpack binary
imarith = "~/software/cexamples/imarith" # imarith
astconvertt = "/usr/local/bin/astconvertt" # GNU astro ConvertType
astarithmetic = "/usr/local/bin/astarithmetic" # GNU astro arithmetic
convert = "/usr/bin/convert" # imagemagick convert
imsize = "/usr/bin/imsize" # imsize

# loop
xdims = ydims = areas = backs = rmss = threshs = nobjs = {}
for(i in 1:length(fnames)){
    
    #cat("\b\b\b\b\b     \b\b\b\b\b", i, " ", sep="", collapse="")
    cat("#####\n ",i,"\n#####\n", sep="", collapse="")
    
    # Source Extractor
    fproc = strsplit(fnames[i], ".fz")[[1]]
    fcat = paste0(strsplit(fnames[i], ".fits.fz")[[1]], ".dat")
    fcheck = paste0(strsplit(fnames[i], ".fits.fz")[[1]], ".check.fits")
    system(paste0(funpack, " -O ", getwd(), "/", fproc, " ", indir, "/", fnames[i]))
    #threshtext = ""
    threshtext = paste0("-THRESH_TYPE ABSOLUTE -DETECT_THRESH 0.07 -ANALYSIS_THRESH 0.07")
    output = system(paste0(sex, " -c default.sex -CATALOG_NAME ", fcat, " -CATALOG_TYPE ASCII -CHECKIMAGE_TYPE SEGMENTATION -CHECKIMAGE_NAME ", fcheck, " ", threshtext, " ", fproc, " 2>&1"), intern=T)
    
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
    
    # areas
    iminfo = strsplit(system(paste0(imsize, " -d ", fproc), intern=TRUE), " +")[[1]]
    degs = as.numeric(strsplit(iminfo[5], "x")[[1]])
    xdims = c(xdims, degs[1])
    ydims = c(ydims, degs[2])
    areas = c(areas, prod(degs))
    
    # SEx stats
    obits = strsplit(grep("RMS:", output, value=TRUE), " +")[[1]]
    backs = c(backs, as.numeric(obits[3]))
    rmss = c(rmss, as.numeric(obits[5]))
    threshs = c(threshs, as.numeric(obits[8]))
    nobjs = c(nobjs, nrow(read.table(fcat, stringsAsFactors=FALSE)))
    
    # clean up
    unlink(c(fproc,fcheck,fbinary,fmodulo,fmodify,jtemp))
    
}

# write areas catalogue
temp = cbind(FILE=fnames, XDIM=xdims, YDIM=ydims, AREA=areas, BACK=backs, RMS=rmss, THRESH=threshs, NOBJ=nobjs)
write.csv(temp, file="imstats.csv", row.names=FALSE, quote=FALSE)

