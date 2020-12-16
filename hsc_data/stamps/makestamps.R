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
ydim = c(522, 522)
zlo = c(-0.3255515,-0.1602886,-0.1501563)
zhi = c(3.674783,2.650155,2.091609)
fwhm = 3

# loop
for(i in 1:length(tractpatch)){

    cat("#####\n ",i,"\n#####\n", sep="", collapse="")

    # setup
    bigsfz = paste0(indirbig, "/calexp-HSC-", toupper(bands), "-", tractpatch[i], ".image.fits.fz")
    bigs = paste0(indirsmall, "/calexp-HSC-", toupper(bands), "-", tractpatch[i], ".image.fits")
    fullrgb = paste0("calexp-HSC-", paste0(toupper(bands), collapse=""), "-", tractpatch[i], ".fullrgb.png")
    fullmon = paste0("calexp-HSC-", toupper(bands[3]), "-", tractpatch[i], ".fullmon.png")
    zoomrgb = paste0("calexp-HSC-", paste0(toupper(bands), collapse=""), "-", tractpatch[i], ".zoomrgb.png")
    zoommon = paste0("calexp-HSC-", toupper(bands[3]), "-", tractpatch[i], ".zoommon.png")

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
    png(file=fullrgb, width=4200, height=4100)
    par("mar"=c(0,0,0,0))

    # plot
    zlim = aimage(input=list(big1,big2,big3), scale.type="atan", scale.lo=zlo, scale.hi=zhi, smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab="", scale.probs=c(0,1))
    lines(x=par("usr")[1]+c(0.05*4200,(0.05*4200)+(200/0.168)), y=par("usr")[3]+c(0.05*4100,0.05*4100), lwd=80, col="white", lend=1)
    text(x=par("usr")[1]+0.05*4200, y=par("usr")[3]+0.1*4100, lab="200 arcsec", col="white", adj=c(0,0.5), cex=16)

    # finish up
    graphics.off()
    system(paste0("/usr/bin/convert -resize 945x ", fullrgb, " ", strsplit(fullrgb, ".png")[[1]], ".jpeg"))
    unlink(fullrgb)

    # dev
    png(file=zoomrgb, width=xdim[i], height=ydim[i])
    par("mar"=c(0,0,0,0))

    # plot
    aimage(input=list(big1,big2,big3), scale.type="atan", scale.lo=zlim[,"0"], scale.hi=zlim[,"1"], smooth.fwhm=fwhm, axes=FALSE, xlab="", ylab="", xcen=xcen[i], ycen=ycen[i], xdim=xdim[i], ydim=ydim[i])
    lines(x=par("usr")[1]+c(0.05*xdim[i],(0.05*xdim[i])+(25/0.168)), y=par("usr")[3]+c(0.05*ydim[i],0.05*ydim[i]), lwd=10, col="white", lend=1)
    text(x=par("usr")[1]+0.05*xdim[i], y=par("usr")[3]+0.1*ydim[i], lab="25 arcsec", col="white", adj=c(0,0.5), cex=2)

    # finish up
    graphics.off()

    # dev
    png(file=fullmon, width=4200, height=4100)
    par("mar"=c(0,0,0,0))

    # plot
    aimage(input=list(big3), scale.type="atan", scale.lo=-0.04, scale.hi=0.2, smooth.fwhm=3, axes=FALSE, xlab="", ylab="", scale.probs=c(0,1), col.map="grey")
    #lines(x=par("usr")[1]+c(0.05*4200,(0.05*4200)+(200/0.168)), y=par("usr")[3]+c(0.05*4100,0.05*4100), lwd=80, col="white", lend=1)
    #text(x=par("usr")[1]+0.05*4200, y=par("usr")[3]+0.1*4100, lab="200 arcsec", col="white", adj=c(0,0.5), cex=16)

    # finish up
    graphics.off()
    system(paste0("/usr/bin/convert -resize 945x ", fullmon, " ", strsplit(fullmon, ".png")[[1]], ".jpeg"))
    unlink(fullmon)

    # segmentation map
    base = strsplit(basename(bigs[3]), ".image.fits")[[1]]
    system(paste0("/usr/bin/convert -resize 945x ../calexp/", base, ".image.png ", base,  ".segmap.jpeg"))

    # finish up
    unlink(bigs)

}

