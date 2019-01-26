#!/usr/bin/Rscript --no-init-file

# definitions
infile = "../sourcecats/calexp-HSC-R-8279-07.image.dat"
dat = read.table(infile, stringsAsFactors=FALSE)
colnames(dat) = c("NUMBER", "FLUX_AUTO", "MAG_AUTO", "KRON_RADIUS", "PETRO_RADIUS", "BACKGROUND", "X_IMAGE", "Y_IMAGE", "A_IMAGE", "B_IMAGE", "THETA_IMAGE", "ELLIPTICITY", "CLASS_STAR", "FLUX_RADIUS")

# binned data
breaks = seq(0,50,by=0.1)
h = hist(dat[,"MAG_AUTO"]+27, breaks=breaks, freq=TRUE, plot=FALSE)

plot(h$mids, h$counts)

