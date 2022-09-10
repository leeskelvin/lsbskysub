# HSC Data

Source HSC data, upon which our LSB simulated images are based.

## Directory Structure

* [calexp](calexp) : HSC SSC DR1 calexp image files (stripped of mask and weight HDUs)
  * files are in the format 'calexp-FACILITY-BAND-TRACT-PATCH.image.fits'
  * originally 57 files, trimmed to two (minimum and maximum density patches)
  * additional raw data added after trimming to final two:
    * GRIZY coverage
    * segmentation check image
    * segmentation check PNG
* [magellip](magellip) : plot of apparent magnitude as a function of half-light radii and ellipticity
  * used to calibrate ellipticities
* [magradii](magradii) : plot of apparent magnitude as a function of half-light radius
  * used to extrapolate half-light radii to the brightest (and faintest) regimes
* [numcounts](numcounts) : plots of galaxy number counts as a function of magnitude
* [patchden](patchden) : analysis of field densities for original 57 HSC SSC DR1 patches
* [psf](psf) : PSF generation, and associated analysis figure
* [sourcecats](sourcecats) : generation of source catalogues for 57 unique tract/patch r-band HSC SSC DR1 images
  * one catalogue and one analysis check image (segmentation map) for each of the original 57 patches
  * additionally contains defaults SExtractor config files
  * threshold level histogram and ancilliary data
* [stamps](stamps) : postage stamp images

## manifest_HSC.rds

A complete manifest of all HSC SSC DR1 files, including WCS information, header data and basic aperture flux tests. File in R RDS data format. See Kelvin et al. 2019 for further information.
