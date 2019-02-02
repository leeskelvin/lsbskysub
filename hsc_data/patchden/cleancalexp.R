#!/usr/bin/Rscript --no-init-file

# chosen ones
chosen = c("calexp-HSC-R-8283-38.image.dat", "calexp-HSC-R-9592-20.image.dat")
mindenfits = paste0(strsplit(chosen[1], ".dat")[[1]], ".fits.fz")
maxdenfits = paste0(strsplit(chosen[2], ".dat")[[1]], ".fits.fz")

# calexp clean
calexpdir = dir("../calexp/")
calexpall = grep(".fits.fz", calexpdir, value=TRUE)
calexpbad = calexpall[-which(calexpall %in% c(mindenfits,maxdenfits))]
if(length(calexpbad) > 0){unlink(paste0("../calexp/", calexpbad))}

# copy segmaps and initial detection catalogues
mindensegmap = paste0(strsplit(chosen[1], ".dat")[[1]], ".png")
maxdensegmap = paste0(strsplit(chosen[2], ".dat")[[1]], ".png")
system(paste0("cp ../sourcecats/", chosen[1], " ../calexp/"))
system(paste0("cp ../sourcecats/", chosen[2], " ../calexp/"))
system(paste0("cp ../sourcecats/", mindensegmap, " ../calexp/"))
system(paste0("cp ../sourcecats/", maxdensegmap, " ../calexp/"))

