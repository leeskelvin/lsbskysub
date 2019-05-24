#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
stilts = "/usr/bin/stilts" # STILTS binary
inputargs = commandArgs(TRUE)
input = inputargs[1] # "/home/lee/lsbskysub/sims/cat-input/calexp-HSC-R-8283-38.cat-input-n1-b.dat" # inputargs[1]
output = inputargs[2] # "/home/lee/lsbskysub/source_extraction/sex_default/cat/denlo1b.cat.csv" # inputargs[2]
outmatch = paste0("mat/", strsplit(basename(output), ".cat.csv")[[1]], ".mat.csv")
dat.input = read.table(input); colnames(dat.input) = c("x", "y", "luminosity_counts", "hlr_pixel", "q", "theta", "n", "stamp_size_pixel")
dat.output = read.csv(output)

# input A/B/AREA
mulim = 35
Ilim = (10^(-0.4*(mulim-27))) * (0.168^2)
a = dat.input[,"hlr_pixel"] / sqrt(dat.input[,"q"])
Ie = sersic.Ie(Ltot=dat.input[,"luminosity_counts"], n=dat.input[,"n"], a=a, e=1-dat.input[,"q"])
a35 = sersic.r(Ir=Ilim, Ie=Ie, n=dat.input[,"n"], a=a)
b35 = a35 * dat.input[,"q"]
area35 = pi * a35 * b35

# new cats
out.input = cbind(
    X_INPUT = dat.input[,"x"]
    ,Y_INPUT = dat.input[,"y"]
    ,MAG_INPUT = -2.5*log10(dat.input[,"luminosity_counts"]) + 27
    ,RAD_INPUT = dat.input[,"hlr_pixel"]
    ,ELLIP_INPUT = 1 - dat.input[,"q"]
    ,THETA_INPUT = dat.input[,"theta"]
    ,A35_INPUT = a35
    ,B35_INPUT = b35
    ,AREA35_INPUT = area35
)
out.output = cbind(
    X_OUTPUT = dat.output[,"x"]
    ,Y_OUTPUT = dat.output[,"y"]
    ,MAG_OUTPUT = -2.5*log10(pmax(dat.output[,"luminosity_counts"],0)) + 27
    ,XX_OUTPUT = dat.output[,"xx"]
    ,YY_OUTPUT = dat.output[,"yy"]
    ,XY_OUTPUT = dat.output[,"xy"]
    ,AREA_OUTPUT = dat.output[,"area_pixel"]
)
bad = which(is.na(out.output[,"MAG_OUTPUT"]))
if(length(bad) > 0){out.output[bad,"MAG_OUTPUT"] = Inf}
write.csv(out.input, file="temp_input.csv", quote=FALSE, row.names=FALSE)
write.csv(out.output, file="temp_output.csv", quote=FALSE, row.names=FALSE)

# run STILTS
system(paste0(
    stilts, " tmatch2"
    , " in1=temp_input.csv in2=temp_output.csv"
    , " ifmt1=csv ifmt2=csv"
    , " out=", outmatch
    , " ofmt=csv"
    , " join=1and2"
    , " progress=none"
    , " matcher=3d_anisotropic"
    , " values1='X_INPUT Y_INPUT MAG_INPUT'"
    , " values2='X_OUTPUT Y_OUTPUT MAG_OUTPUT'"
    , " params='5 5 0.5'"
))

# finish up
unlink(c("temp_input.csv","temp_output.csv"))

