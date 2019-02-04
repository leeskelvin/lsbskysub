#!/usr/bin/Rscript --no-init-file

# definitions
funpack = "/usr/bin/funpack"
fitscopy = "/usr/bin/fitscopy"
tractpatch = c("8283-38", "9592-20")
bands = c("g","r","i","z","y")
xcen = c(350, 3290)
ycen = c(2770, 2280)
xdim = c(535, 535)
ydim = c(535, 535)

# loop
for(i in 1:length(tractpatch)){
    
    # setup
    tpfilesfz = paste0("../calexp/calexp-HSC-", toupper(bands), "-", tractpatch[i], ".image.fits.fz")
    tpfiles = paste0("calexp-HSC-", toupper(bands), "-", tractpatch[i], ".image.fits")
    stampfiles = paste0("calexp-HSC-", toupper(bands), "-", tractpatch[i], ".stamp.fits")
    
    # loop
    for(j in 1:length(tpfiles)){
        
        # unpack
        system(paste0(funpack, " -O ", tpfiles[j], " ", tpfilesfz[i]))
        
        # cutout
        xlo = xcen[i] - (xdim[i]+1)/2
        xhi = xcen[i] + (xdim[i]+1)/2
        ylo = ycen[i] - (ydim[i]+1)/2
        yhi = ycen[i] + (ydim[i]+1)/2
        system(paste0(fitscopy, " ", tpfiles[j], "[", xlo, ":", xhi, ",", ylo, ":", yhi, "] ", stampfiles[j]))
        
        # clean up
        unlink(tpfiles[j])
        
    }
    
}

