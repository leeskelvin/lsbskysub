#!/usr/bin/Rscript --no-init-file

# definitions
indir = normalizePath("../calexp")
fnames = grep(".fits.fz", dir("../calexp"), value=TRUE)
sex = "/usr/bin/sextractor" # local SEx binary

# loop
for(i in 1:length(fnames)){
    
    comm = paste0(sex, " -c sex.config -PARAMETERS_NAME sex.param ", indir, "/", fnames[i])
    
}

