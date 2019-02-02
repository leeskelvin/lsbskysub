#!/usr/bin/Rscript --no-init-file

# definitions
allfiles = dir(); rband = grep(".fits.fz", allfiles, v=T)

# loop
bands = c("G","I","Z","Y")
for(i in 1:length(rband)){
    
    cat("#####\n ",i,"\n#####\n", sep="", collapse="")
    
    # setup
    bits = strsplit(rband[i], "-R-")[[1]]
    bits[2] = strsplit(bits[2], ".fz")[[1]]
    newfiles = paste0(bits[1], "-", bands, "-", bits[2])
    
    # loop
    for(j in 1:length(newfiles)){
        
        # copy
        system(paste0("scp astlkelv@external.astro.ljmu.ac.uk:/gama/survey/hsc/data/image/", newfiles[j], " ."))
        
    }
    
}

# final wrap up
print("If all files successfully downloaded, to compress, run:")
print("fpack -D -Y *.fits")

