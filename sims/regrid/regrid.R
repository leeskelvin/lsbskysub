#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
funpack = "/usr/bin/funpack"
fgauss = "/home/lee/software/heasoft/heasoft-6.25/x86_64-pc-linux-gnu-libc2.27/bin/fgauss"

# definitions
infiles = paste0("../../hsc_data/calexp/", c("calexp-HSC-R-8283-38.image.fits.fz", "calexp-HSC-R-9592-20.image.fits.fz"))

# loop
for(i in 1:length(infiles)){
    
    unpackedfile = strsplit(basename(infiles[i]), ".fz")[[1]]
    if(file.exists(unpackedfile)){unlink(unpackedfile)}
    system(paste(funpack, "-O", unpackedfile, infiles[i]))
    
#    smoothfile = paste0(strsplit(basename(infiles[i]), ".image.fits.fz")[[1]], ".smooth.fits")
#    if(file.exists(smoothfile)){unlink(smoothfile)}
#    system(paste(fgauss, unpackedfile, smoothfile, 125))
    
    imdat = read.fitsim(unpackedfile)
    imdat.small = regrid(imdat, f=1/100)
    
    regridfile = paste0(strsplit(basename(infiles[i]), ".image.fits.fz")[[1]], ".regrid.fits")
    write.fits(imdat.small, file=regridfile)
    
    unlink(unpackedfile)
    
}

