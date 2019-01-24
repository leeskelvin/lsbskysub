#!/usr/bin/Rscript --no-init-file

# setup
dat = readRDS("../manifest_HSC.rds")
unlink("batchfile.txt")

# science files (r band only)
sci = basename(dat[,"SCI"])
scir = grep("-R-", sci, value=TRUE)

# tracts and patches
bits = as.data.frame(t(as.data.frame(strsplit(scir, "-"))), stringsAsFactors=FALSE)
rownames(bits) = NULL
colnames(bits) = c("calexp", "facility", "band", "tract", "patch")
bits[,"patch"] = as.numeric(strsplit(bits[,"patch"], ".image.fits"))
bits[,"tract"] = as.numeric(bits[,"tract"])
utract = unique(bits[,"tract"])
upatch = unique(bits[,"patch"])

# tracts
print(paste0("unique tracts: ", length(utract)))

# loop (starting with least populated tracts, to ensure unique tract/patch coverage)
oo = sort(table(bits[,"tract"]))
badpatch = goodrows = {}
for(i in names(oo)){
    
    rows = which(bits[,"tract"] == as.numeric(i))
    
    if(any(bits[rows,"patch"] %in% badpatch)){
        rows = rows[-which(bits[rows,"patch"] %in% badpatch)]
    }
    
    goodrows = c(goodrows, rows[1])
    badpatch = c(badpatch, bits[rows[1],"patch"])
    
}
goodrows = sort(goodrows)

# final
fin = bits[goodrows,]
fnames = paste0(fin[,"calexp"], "-", fin[,"facility"], "-", fin[,"band"], "-", formatC(fin[,"tract"],format="f",digits=0,width=4,flag=0), "-", formatC(fin[,"patch"],format="f",digits=0,width=2,flag=0), ".image.fits")
cat("progress\n",paste0("get /gama/survey/hsc/data/image/", fnames, " .\n"), file="batchfile.txt", sep="")
if(file.exists("batchfile.txt")){
    print("batchfile successfully created")
    print("now run:")
    print("sftp -b batchfile.txt astlkelv@external.astro.ljmu.ac.uk")
    print("when complete, to compress, run:")
    print("fpack -D -Y *.fits")
}

