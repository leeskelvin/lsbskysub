#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
if(!file.exists("mask")){system("mkdir mask")}
indir = paste0("../", strsplit(basename(getwd()), "_dilated")[[1]][1], "_default/map/")
maps = dir(indir, full.names=TRUE)

# software
gzip = "/bin/gzip"
arithmetic = "/usr/local/bin/astarithmetic"

# loop
for(i in 1:length(maps)){

    # data
    cat(maps[i],"\n")
    system(paste0(gzip, " -d -k ", maps[i]))
    system(paste0("mv ", strsplit(maps[i], ".gz")[[1]], " temp.fits"))
    magdat = read.fitsim("temp.fits", hdu=2)
    #unlink("temp.fits")

    # dilation setup
    umags = sort(unique(magdat[magdat>0]))
    dnum = floor(10^(-0.2*(umags-25))) + 5
    udlist = split(x=umags, f=dnum)
    if("0" %in% names(udlist)){udlist = udlist[-which(names(udlist)=="0")]}

    # loop
    # maskdat = matrix(0, nrow=nrow(magdat), ncol=ncol(magdat))
    maskdat = magdat
    for(j in 1:length(udlist)){

        # setup
        cat("dilate ",names(udlist)[j],"\n",paste(formatC(udlist[[j]],format="f",digits=1),collapse=" "),"\n",sep="")

        # pixel map setup
        tempdat = matrix(0, nrow=nrow(magdat), ncol=ncol(magdat))
        pixels = which(magdat %in% udlist[[j]])
        tempdat[pixels] = 1
        write.fits(list(tempdat,tempdat), file="temp_mask.fits")

        # dilate
        system("cp temp_mask.fits temp_mask_arith.fits")
        for(k in 1:as.numeric(names(udlist)[j])){
            system(paste0(arithmetic, " -q temp_mask_arith.fits uint8 ", (k%%2)+1, " dilate --out=temp_temp.fits"))
            system("mv temp_temp.fits temp_mask_arith.fits")
        }
        tempdat = read.fitsim("temp_mask_arith.fits", hdu=2)
        maskdat = maskdat + tempdat
        unlink(c("temp_mask.fits", "temp_mask_arith.fits"))

    }

    # write and zip
    maskname = strsplit(paste0(strsplit(basename(maps[i]), "map")[[1]], collapse="mask"),".gz")[[1]]
    masknamegz = paste0("mask/", maskname, ".gz")
    unlink(masknamegz)
    write.fits(pmin(maskdat,1), file=maskname) # clip upper range to 1
    system(paste(gzip, "--best --force", maskname))
    system(paste("mv", basename(masknamegz), masknamegz))

    # finish up
    unlink("temp.fits")

}

