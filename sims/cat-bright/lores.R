#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
funpack = "/usr/bin/funpack"
#fgauss = "/home/lee/software/heasoft/heasoft-6.25/x86_64-pc-linux-gnu-libc2.27/bin/fgauss"

# definitions
infiles = paste0("../../hsc_data/calexp/", c("calexp-HSC-R-8283-38.image.fits.fz", "calexp-HSC-R-9592-20.image.fits.fz"))

# dev
png(file="hireslores.png", width=8, height=8, units="in", res=300)

# par
layout(cbind(c(1,2),c(3,4)))
par("oma"=c(0.5,0.5,2,0.5))
par("mar"=c(0.25,0.5,0.25,0.5))

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
    
    loresfile = paste0(strsplit(basename(infiles[i]), ".image.fits.fz")[[1]], ".lores.fits")
    write.fits(imdat.small, file=loresfile)
    
    unlink(unpackedfile)
    
    scale.lo = -0.1
    scale.hi = 25
    aimage(imdat, col.map="sls", scale.type="log", axes=FALSE, scale.lo=-0.1, scale.hi=25)
    #label("topleft", label=c("8283-38 (low density)", "9592-20 (high density)")[i], cex=1.25, col="white")
    mtext(side=3, line=0.5, text=c("8283-38 (low density region)", "9592-20 (high density region)")[i], cex=1.25)
    aimage(imdat.small/(100*100), col.map="sls", scale.type="log", axes=FALSE, scale.lo=scale.lo/10, scale.hi=scale.hi/10)
    
}

# finish up
graphics.off()

