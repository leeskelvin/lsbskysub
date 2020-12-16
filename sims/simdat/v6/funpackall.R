#!/usr/bin/Rscript --no-init-file

funpack = "/home/lee/software/heasoft-6.26.1/x86_64-pc-linux-gnu-libc2.30/bin/funpack"
allfiles = dir()[grep(".fits.fzLEE", paste0(dir(),"LEE"))]

if(length(allfiles) > 0){
    for(i in 1:length(allfiles)){
        system(paste0(funpack, " ", allfiles[i]))
    }
}

