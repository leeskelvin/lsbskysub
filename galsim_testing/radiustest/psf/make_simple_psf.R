#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# software
sex = "/usr/bin/sextractor"
psfex = "/usr/bin/psfex"

# definitions
#psf = matrix(0,25,25); psf[13,13] = 100
#psf = gauss2d(size=55, fwhm=2)*100 + rnorm(n=55*55, mean=0, sd=0.01)
psf = gauss2d(size=55, fwhm=2)*100
psfmap = cbind(psf,psf,psf,psf,psf,psf,psf,psf,psf,psf)
psfmap = rbind(psfmap,psfmap,psfmap,psfmap,psfmap,psfmap,psfmap,psfmap,psfmap,psfmap)
psfmap = psfmap + rnorm(10*55*10*55, mean=0, sd=0.001)
write.fits(psfmap, file="default.fits")

# SExtractor
system(paste0(sex, " -c default.sex -CATALOG_NAME default.fitsldac -CATALOG_TYPE FITS_LDAC -THRESH_TYPE ABSOLUTE -DETECT_THRESH 0.05 -ANALYSIS_THRESH 0.05 -PHOT_APERTURES 30 -GAIN_KEY NOGAINLSK -GAIN 1 -SATUR_KEY NOSATURLSK -SATUR_LEVEL 25 -BACK_TYPE MANUAL -BACK_VALUE 0 -FILTER N default.fits"))

# PSFEx
system(paste0(psfex, " -c default.psfex -PSF_SIZE 55,55 -PSF_RECENTER Y -CHECKPLOT_TYPE NONE -CHECKIMAGE_TYPE NONE -CHECKIMAGE_NAME snap.fits -WRITE_XML N -PSF_SAMPLING 1 -SAMPLE_MINSN 0.1 -SAMPLE_FWHMRANGE 1.0,10.0 -PSFVAR_NSNAP 1 default.fitsldac"))

# clean up
unlink(c("default.fitsldac","default.fits"))
write.fits(psf, file="default.psf.fits")

