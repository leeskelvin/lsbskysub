#!/usr/bin/Rscript --no-init-file

# definitions
sex = "/usr/bin/sextractor"
psfex = "/usr/bin/psfex"
funpack = "/usr/bin/funpack"
fpack = "/usr/bin/fpack"
infile = "../calexp/calexp-HSC-R-8283-38.image.fits.fz"
image = strsplit(basename(infile), ".fz")[[1]][1]
sexcat = paste0(strsplit(basename(infile), ".image.fits.fz")[[1]][1], ".cat.fits")
psffits = paste0(strsplit(basename(infile), ".image.fits.fz")[[1]][1], ".psf.fits")
psfpsf = paste0(strsplit(basename(infile), ".image.fits.fz")[[1]][1], ".psf.psf")
pssample = paste0(strsplit(basename(infile), ".image.fits.fz")[[1]][1], ".pssample.fits")
psresid = paste0(strsplit(basename(infile), ".image.fits.fz")[[1]][1], ".psresid.fits")
pssamplefz = paste0(strsplit(basename(infile), ".image.fits.fz")[[1]][1], ".pssample.fits.fz")
psresidfz = paste0(strsplit(basename(infile), ".image.fits.fz")[[1]][1], ".psresid.fits.fz")

# setup
unlink(c(psffits, psfpsf, pssamplefz, psresidfz, "psfinfo.csv"))
system(paste0(funpack, " -O ", getwd(), "/", image, " ", infile))
man = readRDS("../manifest_HSC.rds")
row = which(basename(man[,"SCI"]) == image)
gain = as.numeric(man[row,"GAIN"])

# SExtractor
system(paste0(sex, " -c default.sex -CATALOG_NAME ", sexcat, " -CATALOG_TYPE FITS_LDAC -THRESH_TYPE ABSOLUTE -DETECT_THRESH 0.07 -ANALYSIS_THRESH 0.07 -PHOT_APERTURES 30 -GAIN_KEY NOGAINLSK -GAIN ", gain, " -SATUR_KEY NOSATURLSK -SATUR_LEVEL 25 ", image, ""))

# PSFEx
output = system(paste0(psfex, " -c default.psfex -PSF_SIZE 55,55 -PSF_RECENTER Y -PSFVAR_NSNAP 1 -CHECKPLOT_TYPE NONE -CHECKIMAGE_TYPE SAMPLES,RESIDUALS,SNAPSHOTS -CHECKIMAGE_NAME samp.fits,resid.fits,snap.fits -WRITE_XML N -PSF_SAMPLING 1 ", sexcat, " 2>&1"), intern=TRUE)

# outputs
bits = strsplit(output[grep("Computing diagnostics",output)+1], " +")[[1]]
accepted = as.numeric(strsplit(bits[2],"/")[[1]][1])
total = as.numeric(strsplit(bits[2],"/")[[1]][2])
sampling = as.numeric(bits[3])
chi2dof = as.numeric(bits[4])
fwhm = as.numeric(bits[5])
ellip = as.numeric(bits[6])
resi = as.numeric(bits[7])
asym = as.numeric(bits[8])
write.csv(cbind(PSF=psffits, ACCEPTED=accepted, TOTAL=total, SAMPLING=sampling, CHI2DOF=chi2dof, FWHM=fwhm, ELLIP=ellip, RESI=resi, ASYM=asym), file="psfinfo.csv", row.names=FALSE, quote=FALSE)

# file renames
system(paste0("mv ", grep("samp_", dir(), value=TRUE), " ", pssample))
system(paste0("mv ", grep("resid_", dir(), value=TRUE), " ", psresid))
system(paste0("mv ", grep("snap_", dir(), value=TRUE), " ", psffits))
system(paste0("mv ", grep(".cat.psf", dir(), value=TRUE), " ", psfpsf))

# pack up sample/residual
system(paste0(fpack, " -D -Y ", pssample))
system(paste0(fpack, " -D -Y ", psresid))

# finish up
unlink(c(sexcat,image))

