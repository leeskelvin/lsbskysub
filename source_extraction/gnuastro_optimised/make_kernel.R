#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
mkprof = "/usr/local/bin/astmkprof"
inputargs = commandArgs(TRUE)
fwhm = as.numeric(inputargs[1])
multiple = as.numeric(inputargs[2])

# run
system(paste0(mkprof, " --oversample=1 --kernel=gaussian,",fwhm,",",multiple,""))

