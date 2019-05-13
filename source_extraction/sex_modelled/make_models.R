#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
if(!file.exists("model")){system("mkdir model")}
psf = "../../hsc_data/psf/calexp-HSC-R-8283-38.psf.psf"
files = grep(".fits.fz", dir("../../sims/simdat/v5/", full.names=TRUE), value=TRUE)
cats = grep(".csv", dir(paste0("../",strsplit(basename(getwd()), "_modelled")[[1]][1],"_default/cat"), full.names=TRUE), value=TRUE)
ids = paste0(c(rep("denlo",4),rep("denhi",4)),gsub("-","",substr(basename(files), 33, 35)))
mulim = 40 # surface brightness limit
stampextra = 0 # extra addition to stamp_size
stampmin = 11 # minimum stamp size

# software
sex = "/usr/bin/sextractor"
funpack = "/usr/bin/funpack"
gzip = "/bin/gzip"
galsim = "/usr/local/bin/galsim"

# loop
for(i in 1:length(files)){
    
    # setup
    cat("", i, "/", length(files), "\n")
    input = cats[grep(ids[i], cats)]
    assoc0 = paste0("model/", ids[i], ".assoc0.dat")
    assoc1 = paste0("model/", ids[i], ".assoc1.dat")
    cat0 = paste0("model/", ids[i], ".model0.dat")
    cat1 = paste0("model/", ids[i], ".model1.dat")
    model0 = paste0("model/", ids[i], ".model0.fits")
    model1 = paste0("model/", ids[i], ".model1.fits")
    
    # unpack
    system(paste(funpack, "-O temp.fits", files[i]))
    
    # model0 ASSOC
    catdat = read.csv(input)
    samp = which(catdat[,"MAG_AUTO"] <= 22)
    write.table(cbind(1:length(samp), catdat[samp,"X_IMAGE"], catdat[samp,"Y_IMAGE"], catdat[samp,"MAG_AUTO"]), file=assoc0, quote=FALSE, row.names=FALSE, col.names=FALSE)
    
    # model0 SEx
    output = system(paste0(sex, " -c ../sex_default/default.sex -ASSOC_NAME ", assoc0, " -PARAMETERS_NAME model.param -PSF_NAME ", psf, " -CHECKIMAGE_TYPE MODELS -CHECKIMAGE_NAME ", model0, " -CATALOG_NAME ", cat0, " -MAG_ZEROPOINT 27 temp.fits 2>&1"), intern=T)
    system(paste(gzip, "--best --force", model0))
    
    # model1 ASSOC
    cat0dat = read.table(cat0)
    colnames(cat0dat) = c("NUMBER", "X_IMAGE", "Y_IMAGE", "FLUX_SPHEROID", "MAG_SPHEROID", "SPHEROID_REFF_IMAGE", "SPHEROID_ASPECT_IMAGE", "SPHEROID_THETA_IMAGE", "SPHEROID_SERSICN", "CHI2_MODEL", "FLAGS_MODEL", "VECTOR_ASSOC")
    chi2median = median(cat0dat[,"CHI2_MODEL"])
    chi2mad = mad(cat0dat[,"CHI2_MODEL"])
    good = which(cat0dat[,"CHI2_MODEL"] >= chi2median-3*chi2mad & cat0dat[,"CHI2_MODEL"] <= chi2median+3*chi2mad)
    stamp_size = pmax((1 + stampextra + 2*ceiling(sersic.mu2r(mu=mulim, mag=cat0dat[good,"MAG_SPHEROID"], n=cat0dat[good,"SPHEROID_SERSICN"], re=cat0dat[good,"SPHEROID_REFF_IMAGE"], e=1-cat0dat[good,"SPHEROID_ASPECT_IMAGE"]))),stampmin) # pixels
    temp = cbind(X=cat0dat[good,"X_IMAGE"], Y=cat0dat[good,"Y_IMAGE"], FLUX=cat0dat[good,"FLUX_SPHEROID"], HLR=cat0dat[good,"SPHEROID_REFF_IMAGE"], Q=cat0dat[good,"SPHEROID_ASPECT_IMAGE"], THETA=cat0dat[good,"SPHEROID_THETA_IMAGE"], N=cat0dat[good,"SPHEROID_SERSICN"], STAMP_SIZE=stamp_size)
    write.table(temp, file="temp-input.dat", quote=FALSE, row.names=FALSE, col.names=FALSE)
    system(paste(galsim, "feedme.yaml"))
    
    # model1 SEx
    output = system(paste0(sex, " -c ../sex_default/default.sex -ASSOC_NAME ", assoc1, " -PARAMETERS_NAME model.param -PSF_NAME ", psf, " -CHECKIMAGE_TYPE MODELS -CHECKIMAGE_NAME ", model1, " -CATALOG_NAME ", cat1, " -MAG_ZEROPOINT 27 temp.fits 2>&1"), intern=T)
    system(paste(gzip, "--best --force", model1))
    
    # finish up
    unlink("temp.fits")
    
}

