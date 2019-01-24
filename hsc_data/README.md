# HSC Data Files

Source HSC data, upon which our LSB simulated images are based

## Sub-folder Structure

* [calexp](calexp) : HSC SSC DR1 calexp image files (stripped of mask and weight HDUs)
  * files are in the format 'calexp-FACILITY-BAND-TRACT-PATCH.image.fits'.
* [sourcecats](sourcecats) : generation of source catalogues for 57 unique tract/patch r-band HSC SSC DR1 images.

## manifest_HSC.rds

A complete manifest of all HSC SSC DR1 files, including WCS information, header data and basic aperture flux tests. File in R RDS data format. See Kelvin et al. 2019 for further information.

