#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
stilts = "/usr/bin/stilts" # STILTS binary
inputargs = commandArgs(TRUE)
input = inputargs[1] # "/home/lee/lsbskysub/sims/cat-input/calexp-HSC-R-8283-38.cat-input-n1-b.dat" # inputargs[1]
output = inputargs[2] # "/home/lee/lsbskysub/source_extraction/gnuastro_default/cat/denlo1b.cat.csv" # inputargs[2]
outmatch = paste0("mat/", strsplit(basename(output), ".cat.csv")[[1]], ".mat.csv")
dat.input = read.table(input); colnames(dat.input) = c("x","y","flux","half_light_radius","q","theta","n","stamp_size")
dat.output = read.csv(output)

# input A40/B40/AREA40
a40 = sersic.mu2r(mu=40, mag=(-2.5*log10(dat.input[,"flux"])+27), n=dat.input[,"n"], re=dat.input[,"half_light_radius"]/0.168, e=1-dat.input[,"q"])
b40 = dat.input[,"q"] * a40
area40 = pi * a40 * b40 # pixels^2

# new cats
out.input = cbind(
    X_INPUT = dat.input[,"x"]
    ,Y_INPUT = dat.input[,"y"]
    ,MAG_INPUT = -2.5*log10(dat.input[,"flux"]) + 27
    ,RAD_INPUT = dat.input[,"half_light_radius"] # arcsec
    ,ELLIP_INPUT = 1 - dat.input[,"q"]
    ,THETA_INPUT = dat.input[,"theta"]
    ,A40_INPUT = a40
    ,B40_INPUT = b40
    ,AREA40_INPUT = area40
)
out.output = cbind(
    X_OUTPUT = dat.output[,"X"]
    ,Y_OUTPUT = dat.output[,"Y"]
    ,MAG_OUTPUT = -2.5*log10(pmax(dat.output[,"BRIGHTNESS"],0)) + 27
    ,RAD_OUTPUT = pmax(dat.output[,"SEMI_MAJOR"],0) * 0.168 # arcsec
    ,ELLIP_OUTPUT = dat.output[,"ELLIPTICITY"]
    ,THETA_OUTPUT = dat.output[,"POSITION_ANGLE"]
    ,A_OUTPUT = dat.output[,"SEMI_MAJOR"]
    ,B_OUTPUT = dat.output[,"SEMI_MINOR"]
    ,AREA_OUTPUT = dat.output[,"AREA"]
)
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

