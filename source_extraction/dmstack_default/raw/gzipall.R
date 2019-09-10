#!/usr/bin/Rscript --no-init-file

gzip = "/bin/gzip"
allfiles = dir()[grep(".csvLEE", paste0(dir(),"LEE"))]

if(length(allfiles) > 0){
    for(i in 1:length(allfiles)){
        system(paste0(gzip, " --best ", allfiles[i]))
    }
}

