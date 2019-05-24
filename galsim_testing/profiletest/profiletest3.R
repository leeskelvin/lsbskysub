#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
pixelsize = 0.168
input = "../../sims/cat-input/calexp-HSC-R-8283-38.cat-input-n1-a.dat"
dat = read.table(input)
colnames(dat) = c("x","y","luminosity_counts","hlr_pixel","q","theta","n","stamp_size_pixel")
rows = c(1:25,sample(nrow(dat),size=25))

# loop
asb = gfsb = afaints = gffaints = {}
for(i in 1:length(rows)){
    
    # subdat
    row = rows[i]
    Ltot = dat[row,"luminosity_counts"]
    re = dat[row,"hlr_pixel"]
    q = dat[row,"q"]
    n = dat[row,"n"]
    stamp_size = dat[row,"stamp_size_pixel"]
    a = round(re / sqrt(q),digits=2)
    e = 1 - q
    xcen = ycen = (stamp_size+1)/2
    mag = round(-2.5 * log10(Ltot),digits=2)
    
    # astro
    rads = 1:xcen-1
    Ie = sersic.Ie(Ltot=Ltot, n=n, a=a, e=e)
    acounts = sersic.Ir(r=rads, Ie=Ie, n=n, a=a)
    asb = c(asb, list(-2.5*log10(acounts/(pixelsize^2)) + 27))
    afaints = c(afaints, max(asb[[i]]))
    
    # GALFIT
    config = readLines("galfit-pt3.config")
    config[grep("Image region to fit",config)] = paste0("H) 1 ",stamp_size," 1 ",stamp_size," # Image region to fit")
    config[grep("Size of convolution box",config)] = paste0("I) ", stamp_size," ", stamp_size, " # Size of convolution box")
    config[grep("position x, y",config)] = paste0(" 1) ",xcen," ",ycen," 0 0 # position x, y")
    config[grep("total magnitude",config)] = paste0(" 3) ",mag," 0 # total magnitude")
    config[grep("R_e",config)] = paste0(" 4) ",a," 0 # R_e")
    config[grep("Sersic exponent",config)] = paste0(" 5) ",n," 0 # Sersic exponent")
    config[grep("axis ratio",config)] = paste0(" 9) ",q," 0 # axis ratio")
    cat(config, file="galfit-pt3.config", sep="\n")
    system("~/software/galfit/galfit galfit-pt3.config")
    gfdat = read.fitsim("galfit-pt3.fits")
    gfcounts = gfdat[xcen:stamp_size,ycen]
    gfsb = c(gfsb, list(-2.5*log10(gfcounts/(pixelsize^2)) + 27))
    gffaints = c(gffaints, max(gfsb[[i]]))
    
}

# par


# plot
aplot(NA, xlim=c(0,200), ylim=c(50,15))

# loop
for(i in 1:length(asb)){
    lines(asb[[i]], col=1)
    lines(gfsb[[i]], col=2)
}

# finish up



# par


# plot
aplot(afaints, col=1)
points(gffaints, col=2)

# finish up

