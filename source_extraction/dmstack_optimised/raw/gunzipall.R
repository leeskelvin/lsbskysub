#!/usr/bin/Rscript --no-init-file

gunzip = "/bin/gunzip"
allfiles = dir()[grep(".csv.gzLEE", paste0(dir(),"LEE"))]

if(length(allfiles) > 0){
    for(i in 1:length(allfiles)){
        system(paste0(gunzip, " ", allfiles[i]))
    }
}

