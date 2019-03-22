#!/usr/bin/Rscript --no-init-file

funpack = "/home/lee/software/heasoft/heasoft-6.25/x86_64-pc-linux-gnu-libc2.27/bin/funpack"
allfiles = grep(".fits", dir(), v=T)

for(i in 1:length(allfiles)){
    system(paste0(funpack, " ", allfiles[i]))
}

