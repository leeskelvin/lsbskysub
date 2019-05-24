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
mulim = 35
Ilim = (10^(-0.4*(mulim-27))) * (0.168^2)
stampmin = 11

# software
sex = "/usr/bin/sextractor"
funpack = "/usr/bin/funpack"
fpack = "/usr/bin/fpack"
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
    cat1 = paste0("model/", ids[i], ".model1.csv")
    model0 = paste0("model/", ids[i], ".model0.fits")
    model1 = paste0("model/", ids[i], ".model1.fits")
    
    # unpack
    system(paste(funpack, "-O temp.fits", files[i]))
    
    # model0 ASSOC
    catdat = read.csv(input)
    samp = which(catdat[,"MAGNITUDE"] <= 22)
    write.table(cbind(1:length(samp), catdat[samp,"X"], catdat[samp,"Y"], catdat[samp,"MAGNITUDE"]), file=assoc0, quote=FALSE, row.names=FALSE, col.names=FALSE)
    
    # model0 SEx
    output = system(paste0(sex, " -c ../sex_default/default.sex -ASSOC_NAME ", assoc0, " -PARAMETERS_NAME model.param -PSF_NAME ", psf, " -CHECKIMAGE_TYPE MODELS -CHECKIMAGE_NAME ", model0, " -CATALOG_NAME ", cat0, " -MAG_ZEROPOINT 27 temp.fits 2>&1"), intern=T)
    #system(paste(gzip, "--best --force", model0))
    system(paste0(fpack, " -D -Y ", model0))
    
    # model1 ASSOC
    cat0dat = read.table(cat0)
    colnames(cat0dat) = c("NUMBER", "X_IMAGE", "Y_IMAGE", "FLUX_SPHEROID", "MAG_SPHEROID", "SPHEROID_REFF_IMAGE", "SPHEROID_ASPECT_IMAGE", "SPHEROID_THETA_IMAGE", "SPHEROID_SERSICN", "CHI2_MODEL", "FLAGS_MODEL", "VECTOR_ASSOC")
    chi2median = median(cat0dat[,"CHI2_MODEL"])
    chi2mad = mad(cat0dat[,"CHI2_MODEL"])
    good = which(cat0dat[,"CHI2_MODEL"] >= chi2median-3*chi2mad & cat0dat[,"CHI2_MODEL"] <= chi2median+3*chi2mad)
    Ie = sersic.Ie(Ltot=cat0dat[,"FLUX_SPHEROID"], n=cat0dat[,"SPHEROID_SERSICN"], a=cat0dat[,"SPHEROID_REFF_IMAGE"], e=1-cat0dat[,"SPHEROID_ASPECT_IMAGE"])
    rlim = sersic.r(Ir=Ilim, Ie=Ie, n=cat0dat[,"SPHEROID_SERSICN"], a=cat0dat[,"SPHEROID_REFF_IMAGE"])
    stamp_size_pixel = 1 + 2*ceiling(rlim)
    # digits: x=1, y=1, luminosity_counts=4, hlr_pixels=3, q=2, theta=1, n=1 (max 4.5)
    # n to 1 digit, as Henkel transforms in GalSim pre-compute Sersic models -> significant speed up
    # n max 4.5 due to: RuntimeError: Roundoff error 2 prevents tolerance from being achieved in intGKP
    # maximum_fft_size updated due to error: 
        # galsim.errors.GalSimFFTSizeError: drawFFT requires an FFT that is too large.
        # The required FFT size would be 8256 x 8256, which requires 1.52 GB of memory.
        # If you can handle the large FFT, you may update gsparams.maximum_fft_size.
    temp = cbind(
        X = formatC(cat0dat[good,"X_IMAGE"], format="f", digits=1)
        , Y = formatC(cat0dat[good,"Y_IMAGE"], format="f", digits=1)
        , LUMINOSITY_COUNTS = formatC(cat0dat[good,"FLUX_SPHEROID"], format="f", digits=5)
        , HLR_PIXEL = formatC(cat0dat[good,"SPHEROID_REFF_IMAGE"] * sqrt(cat0dat[good,"SPHEROID_ASPECT_IMAGE"]), format="f", digits=3)
        , Q = formatC(cat0dat[good,"SPHEROID_ASPECT_IMAGE"], format="f", digits=2)
        , THETA = formatC(cat0dat[good,"SPHEROID_THETA_IMAGE"], format="f", digits=1)
        , N = round(pmin(cat0dat[good,"SPHEROID_SERSICN"],4.5), digits=1)
        , STAMP_SIZE_PIXEL = stamp_size_pixel[good]
    )
    write.table(temp, file="temp-input.dat", quote=FALSE, row.names=FALSE, col.names=FALSE)
    
    # model1 GalSim
    system(paste(galsim, "feedme.yaml"))
    if(!file.exists("temp-model.fits")){stop("GalSim output file missing")}
    system(paste("mv temp-input.dat", assoc1))
    system(paste("mv temp-model.fits", model1))
    #system(paste(gzip, "--best --force", model1))
    system(paste0(fpack, " -D -Y ", model1))
    temp = cbind(NTOTALDEFAULT=nrow(catdat), NBRIGHT=length(samp), NGOOD=length(good), CHI2MEDIAN=chi2median, CHI2MAD=chi2mad)
    write.csv(temp, file=cat1, row.names=FALSE, quote=FALSE)
    
    # finish up
    unlink("temp.fits")
    
}

