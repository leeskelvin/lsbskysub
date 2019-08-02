#!/usr/bin/Rscript --no-init-file

fpack = "/home/lee/software/heasoft/x86_64-pc-linux-gnu-libc2.27/bin/fpack"
allfiles = dir()[grep(".fitsLEE", paste0(dir(),"LEE"))]

if(length(allfiles) > 0){
    for(i in 1:length(allfiles)){
        system(paste0(fpack, " -D ", allfiles[i]))
    }
}

