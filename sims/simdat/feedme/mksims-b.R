#!/usr/bin/Rscript --no-init-file

# setup
#require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# run GalSim : bright
system("/usr/local/bin/galsim calexp-HSC-R-8283-38.feedme-n1-b.yaml")
system("/usr/local/bin/galsim calexp-HSC-R-8283-38.feedme-n4-b.yaml")
system("/usr/local/bin/galsim calexp-HSC-R-9592-20.feedme-n1-b.yaml")
system("/usr/local/bin/galsim calexp-HSC-R-9592-20.feedme-n4-b.yaml")

## run GalSim : all
#system("/usr/local/bin/galsim calexp-HSC-R-8283-38.feedme-n1-a.yaml")
#system("/usr/local/bin/galsim calexp-HSC-R-8283-38.feedme-n4-a.yaml")
#system("/usr/local/bin/galsim calexp-HSC-R-9592-20.feedme-n1-a.yaml")
#system("/usr/local/bin/galsim calexp-HSC-R-9592-20.feedme-n4-a.yaml")

