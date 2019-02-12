#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)

# definitions
funpack = "/usr/bin/funpack"
inbase = "calexp-HSC-R-8283-38"
imagefz = paste0("../calexp/", inbase, ".image.fits.fz")
image = paste0(inbase, ".image.fits")
segfz = paste0("../calexp/", inbase, ".image.check.fits.fz")
seg = paste0(inbase, ".image.check.fits")

# setup
system(paste0(funpack, " -O ", image, " ", imagefz))
system(paste0(funpack, " -O ", seg, " ", segfz))
imdat = backdat = read.fitsim(image)
segdat = read.fitsim(seg)
backdat[segdat > 0] = NA

# jackknife
xx = seq(1, dim(backdat)[1], len=11)
yy = seq(1, dim(backdat)[2], len=11)
means = {}
for(i in 2:length(xx)){
    for(j in 2:length(yy)){
        ijdat = backdat[(xx[i-1]):(xx[i]),(yy[j-1]):(yy[j])]
        means = c(means, mean(ijdat, na.rm=TRUE))
    }
}

# write
quants = quantile(means, c(0.025,0.975,0.005,0.995)) - median(means)
write.csv(cbind(SD=sd(means), ERR95LO=quants[1], ERR95HI=quants[2], ERR99LO=quants[3], ERR99HI=quants[4]), file="skyerr.csv", row.names=FALSE, quote=FALSE)

# finish up
unlink(c(image,seg))

