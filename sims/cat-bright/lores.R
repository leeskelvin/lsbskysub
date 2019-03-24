#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
funpack = "/usr/bin/funpack"
#fgauss = "/home/lee/software/heasoft/heasoft-6.25/x86_64-pc-linux-gnu-libc2.27/bin/fgauss"

# definitions
infiles = paste0("../../hsc_data/calexp/", c("calexp-HSC-R-8283-38.image.fits.fz", "calexp-HSC-R-9592-20.image.fits.fz"))

# dev
png(file="hireslores.png", width=8, height=7.81, units="in", res=200)

# par
insetcm = 0.5
layout(cbind(c(1,1,1,3,3,3),c(1,2,1,3,3,3),c(1,1,1,3,3,3),c(4,4,4,6,6,6),c(4,5,4,6,6,6),c(4,4,4,6,6,6)), widths=c(lcm(insetcm),1,1,lcm(insetcm),1,1), heights=c(1,1,lcm(insetcm),lcm(insetcm),1,1))
par("oma"=c(0.5,2,2,0.5))
#par("mar"=c(0.25,0.25,0.25,0.25))

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
    
    fwhm = 3
    xcen = c(350, 3290)
    ycen = c(2770, 2280)
    xdim = c(535, 535)
    ydim = c(535, 535)
    xlo = round(xcen[i] - ((xdim[i]+1)/2))
    xhi = round(xcen[i] + ((xdim[i]+1)/2))
    ylo = round(ycen[i] - ((ydim[i]+1)/2))
    yhi = round(ycen[i] + ((ydim[i]+1)/2))
    par("mar"=c(0.25,0.25,0.25,0.25))
    aimage(imdat, col.map="sls", scale.type="log", axes=FALSE, scale.lo=-0.025, scale.hi=5, smooth.fwhm=fwhm, xlab="", ylab="")
    rect(xl=xlo, xr=xhi, yb=ylo, yt=yhi, border="grey0", lwd=3)
    mtext(side=3, line=0.5, text=c("8283-38 (low density region)", "9592-20 (high density region)")[i], cex=1.25)
    if(i==1){mtext(side=2, line=0.5, text="full resolution image", cex=1.25)}
    par("mar"=c(0,0,0,0))
    aimage(imdat, col.map="sls", scale.type="log", axes=FALSE, scale.lo=-0.025, scale.hi=5, smooth.fwhm=fwhm, xcen=xcen[i], ycen=ycen[i], xdim=xdim[i], ydim=ydim[i], xlab="", ylab="")
    box(lwd=5, col="grey0")
    par("mar"=c(0.25,0.25,0.25,0.25))
    aimage(imdat.small/(100*100), col.map="sls", scale.type="log", axes=FALSE, scale.lo=-0.1/10, scale.hi=25/10, xlab="", ylab="")
    if(i==1){mtext(side=2, line=0.5, text="low resolution image", cex=1.25)}
    
}

# finish up
graphics.off()

