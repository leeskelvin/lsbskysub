#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
inputargs = commandArgs(TRUE)
fwhm = as.numeric(inputargs[1])
multiple = as.numeric(inputargs[2])
size = round(multiple*fwhm)
if(size %% 2 == 0){size = size + 1}

# kernel
cat("CONV NORM\n", file="kernel.conv")
write.table(formatC(gauss2d(size=size, fwhm=fwhm), format="f", digits=5), file="kernel.conv", row.names=FALSE, col.names=FALSE, quote=FALSE, append=TRUE)

