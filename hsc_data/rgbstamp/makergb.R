#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)

# definitions
funpack = "/usr/bin/funpack"
indirbig = normalizePath("../calexp")
indirsmall = normalizePath(".")
tractpatch = c("8283-38", "9592-20")
bands = c("z","i","r")
xcen = c(350, 3290)
ycen = c(2770, 2280)
xdim = c(535, 535)
ydim = c(535, 535)
zlo = c(-0.3255515,-0.1602886,-0.1501563)
zhi = c(3.674783,2.650155,2.091609)

# loop
for(i in 1:length(tractpatch)){
    
    cat("#####\n ",i,"\n#####\n", sep="", collapse="")
    
    # setup
    bigsfz = paste0(indirbig, "/calexp-HSC-", toupper(bands), "-", tractpatch[i], ".image.fits.fz")
    bigs = paste0(indirsmall, "/calexp-HSC-", toupper(bands), "-", tractpatch[i], ".image.fits")
    #smalls = paste0(indirsmall, "/calexp-HSC-", toupper(bands), "-", tractpatch[i], ".stamp.fits")
    stamp = paste0("calexp-HSC-", paste0(toupper(bands), collapse=""), "-", tractpatch[i], ".stamp.png")
    
    # funpack
    for(j in 1:length(bigsfz)){
        system(paste0(funpack, " -O ", bigs[j], " ", bigsfz[j]))
    }
    
    # read
    big1 = read.fitsim(bigs[1])
    big2 = read.fitsim(bigs[2])
    big3 = read.fitsim(bigs[3])
    
    # x/y lo/hi
    xlo = round(xcen[i] - ((xdim[i]+1)/2))
    xhi = round(xcen[i] + ((xdim[i]+1)/2))
    ylo = round(ycen[i] - ((ydim[i]+1)/2))
    yhi = round(ycen[i] + ((ydim[i]+1)/2))
    
    # dev
    png(file=stamp, width=8, height=8, units="in", res=300)
    par("mar"=c(0,0,0,0))
    layout(rbind(c(1,1,1),c(1,2,1),c(1,1,1)), widths=c(lcm(1),1,1), heights=c(1,1,lcm(1)))
    
    # plot
    fwhm = 3
    zlim = aimage(input=list(big1,big2,big3), scale.type="atan", scale.lo=zlo, scale.hi=zhi, smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab="", scale.probs=c(0,1), xdim=4100, ydim=4100)
    print(zlim)
    rect(xl=xlo, xr=xhi, yb=ylo, yt=yhi, border="grey50", lwd=3)
    aimage(input=list(big1,big2,big3), scale.type="atan", scale.lo=zlim[,"0%"], scale.hi=zlim[,"100%"], smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab="", xcen=xcen[i], ycen=ycen[i], xdim=xdim[i], ydim=ydim[i])
    box(lwd=5, col="grey50")
    
    # finish up
    graphics.off()
    unlink(bigs)
    
}

