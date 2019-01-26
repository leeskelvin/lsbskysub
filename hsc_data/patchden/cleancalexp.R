#!/usr/bin/Rscript --no-init-file

# definitions
dat = read.csv("patchden.csv", stringsAsFactors=FALSE)

# chosen ones
mindencat = dat[which.min(dat[,"NUMDEN"]),"CAT"]
maxdencat = dat[which.max(dat[,"NUMDEN"]),"CAT"]
mindenfits = paste0(strsplit(mindencat, ".dat")[[1]], ".fits.fz")
maxdenfits = paste0(strsplit(maxdencat, ".dat")[[1]], ".fits.fz")

# calexp
calexpdir = dir("../calexp/")
calexpall = grep(".fits.fz", calexpdir, value=TRUE)
calexpbad = calexpall[-which(calexpall %in% c(mindenfits,maxdenfits))]
unlink(paste0("../calexp/", calexpbad))

