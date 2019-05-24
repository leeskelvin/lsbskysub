#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
pixelsize = 0.168
mulim = 35
Ilim = 10^(-0.4*(mulim-27)) * (pixelsize^2)
stampmin = 11

# generate cats
maindir = getwd()
setwd("../cat-bright"); system("./mkbright.R 1"); system("./mkbright.R 4")
setwd("../cat-detused"); system("./mkdetused.R 1"); system("./mkdetused.R 4")
setwd("../cat-faint"); system("./mkfaint.R 1"); system("./mkfaint.R 4")
setwd(maindir)

# catalogues
brights = paste0("../cat-bright/", grep(".cat-", dir("../cat-bright"), value=TRUE))
detuseds = paste0("../cat-detused/", grep(".cat-", dir("../cat-detused"), value=TRUE))
faints = paste0("../cat-faint/", grep(".cat-", dir("../cat-faint"), value=TRUE))

# loop
for(i in 1:length(brights)){
    
    # setup
    catlist = c(brights[i], detuseds[i], faints[i])
    base = strsplit(strsplit(basename(brights[i]), ".csv")[[1]], ".cat-bright")[[1]]
    outaname = paste0(base[1], ".cat-input", base[2], "-a.dat")
    outbname = paste0(base[1], ".cat-input", base[2], "-b.dat")
    
    # loop
    res = {}
    for(j in 1:length(catlist)){
        
        # setup
        dat = read.csv(catlist[j])
        
        # stamp sizes
        a = dat[,"hlr_pixel"] / sqrt(dat[,"q"])
        Ie = sersic.Ie(Ltot=dat[,"luminosity_counts"], n=dat[,"n"], a=a, e=1-dat[,"q"])
        rlim = sersic.r(Ir=Ilim, Ie=Ie, n=dat[,"n"], a=a)
        stamp_size_pixel = pmax(1 + 2*ceiling(rlim), stampmin)
        dat = cbind(dat, stamp_size_pixel=stamp_size_pixel)
        
        # save to res
        res = c(res, list(dat))
        
    }
    
    # output a/b catalogues
    outa = rbind(res[[1]], res[[2]], res[[3]])
    outb = rbind(res[[1]], res[[2]])
    
    # save data to GalSim readable file
    write.table(outa, file=outaname, sep=" ", row.names=FALSE, quote=FALSE, col.names=FALSE)
    write.table(outb, file=outbname, sep=" ", row.names=FALSE, quote=FALSE, col.names=FALSE)
    
}

