#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
denlo1a = "../../sims/simdat/v3/calexp-HSC-R-8283-38.simulated-n1.fits.fz"
denlo1b = "../../sims/simdat/v3/calexp-HSC-R-8283-38.simulated-n1-nofaint.fits.fz"
denlo4a = "../../sims/simdat/v3/calexp-HSC-R-8283-38.simulated-n4.fits.fz"
denlo4b = "../../sims/simdat/v3/calexp-HSC-R-8283-38.simulated-n4-nofaint.fits.fz"
denhi1a = "../../sims/simdat/v3/calexp-HSC-R-9592-20.simulated-n1.fits.fz"
denhi1b = "../../sims/simdat/v3/calexp-HSC-R-9592-20.simulated-n1-nofaint.fits.fz"
denhi4a = "../../sims/simdat/v3/calexp-HSC-R-9592-20.simulated-n4.fits.fz"
denhi4b = "../../sims/simdat/v3/calexp-HSC-R-9592-20.simulated-n4-nofaint.fits.fz"
files = c(denlo1a, denlo1b, denlo4a, denlo4b, denhi1a, denhi1b, denhi4a, denhi4b)
bases = c("denlo1a", "denlo1b", "denlo4a", "denlo4b", "denhi1a", "denhi1b", "denhi4a", "denhi4b")
noisechisel = "/usr/local/bin/astnoisechisel" # local noisechisel binary
segment = "/usr/local/bin/astsegment" # local segment binary
mkcatalog = "/usr/local/bin/astmkcatalog" # local mkcatalog binary
funpack = "/usr/bin/funpack" # local FITS unpack binary
fpack = "/usr/bin/fpack" # local FITS pack binary
gzip = "/bin/gzip" # local gzip binary

# loop
backs = rmss = threshs = nobjs = {}
for(i in 1:length(files)){
    
    # setup
    cat("", i-1, "/", length(files), "\n")
    #segmap = paste0(bases[i], ".segmap.fits")
    #magmap = paste0(bases[i], ".magmap.fits")
    #detected = paste0(bases[i], ".detected.fits")
    
    # unpack
    system(paste(funpack, "-O temp.fits", files[i]))
    
    # noisechisel
    system(paste(noisechisel, "-h0 temp.fits"))
    #detdat = read.fits(detected)
    #system(paste(gzip, "--best --force", detected))
    
    # segment
    system(paste(segment, "temp_detected.fits"))
    
    # clean up
    unlink(c("temp.fits"))
    
}

# write statistics
temp = cbind(ID=bases, BACK=backs, RMS=rmss, THRESH=threshs, NOBJ=nobjs)
write.csv(temp, file=paste0("stats_",basename(getwd()),".csv"), row.names=FALSE, quote=FALSE)

# finish up
cat(" 8 / 8\n")

