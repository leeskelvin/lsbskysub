# Source Extractor (Defaults)

SExtractor version 2.19.5 (2013-12-14)

Files 'default.sex' and 'default.param' generated on the command line: 'sextractor -dd' and 'sextractor 'dp' respectively.

Files 'default.nnw' and 'default.conv' taken from https://astromatic.net/redmine/projects/sextractor/repository/revisions/332/show

* https://astromatic.net/redmine/projects/sextractor/repository/revisions/332/entry/config/default.nnw
* https://astromatic.net/redmine/projects/sextractor/repository/revisions/332/entry/config/default.conv

The script 'makecats.R' is first run without any given threshold level, allowing SExtractor to find its own level at 1.5 sigma for each image. Then the script 'threshlvls.R' is run to analyse the recovered threshold levels, producing the analysis plot 'threshlvls.pdf'. Following this, the catalogues and check images are deleted, and an explicit threshold level in ADUs is selected, to be applied to each image globally. The script 'makecats.R' is once more run. This aides in a global comparison across all images. 

