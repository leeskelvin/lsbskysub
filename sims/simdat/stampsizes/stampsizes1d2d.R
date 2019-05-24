#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
v5dat1 = read.table("v5/calexp-HSC-R-8283-38.cat-input-n1-b.dat")
v5dat2 = read.table("v5/calexp-HSC-R-8283-38.cat-input-n4-b.dat")
v5dat3 = read.table("v5/calexp-HSC-R-9592-20.cat-input-n1-b.dat")
v5dat4 = read.table("v5/calexp-HSC-R-9592-20.cat-input-n4-b.dat")
v5dat = rbind(v5dat1,v5dat2,v5dat3,v5dat4)
colnames(v5dat) = c("x","y","flux","half_light_radius","q","theta","n","stamp_size")
mulim = 40 # mag/sq.arcsec
n = v5dat[,"n"]
re = v5dat[,"half_light_radius"] / 0.168 # pixels
flux = v5dat[,"flux"]
mag = -2.5*log10(flux) + 27
stamp_size = v5dat[,"stamp_size"]
q = v5dat[,"q"]

# definitions 2
e = 1-q
a = re * sqrt(q)
Ilimpix = (10^(-0.4*(mulim-27))) * (0.168^2) # ADU/sq.arcsec * sq.arcsec/pixel = ADU/pixel
Ie = sersic.Ie(Ltot=flux, n=n, a=a, e=e)
rlim = sersic.r(Ir=Ilimpix, Ie=Ie, n=n, a=a) # pixel
rlim_size = 1 + 2*ceiling(rlim)
Ie.old = sersic.Ie(Ltot=flux, n=n, a=a, e=0)
rlim.old = sersic.r(Ir=Ilimpix, Ie=Ie.old, n=n, a=a) # pixel
rlim_size.old = 1 + 2*ceiling(rlim.old)

sersic.mu2r = function(mu, mag = 0, n = 1, re = 1, e = 0){
    bn = qgamma(0.5,2*n)
    lumtot = 1*(re^2)*2*pi*n*((exp(bn))/(bn^(2*n)))*gamma(2*n)*(1-e)
    magtot = -2.5*log10(lumtot)
    Ie = 1/(10^(0.4*(mag-magtot)))
    intenr = 10^(-0.4*mu)
    rmu = re*((((log(intenr/Ie))/(-bn))+1)^n)
    return(rmu)
}

rad.old.arcsec = sersic.mu2r(mu=mulim, mag=mag, n=n, re=re*0.168, e=e)
rad.old.pixels = rad.old.arcsec / 0.168
stamp_size.old = 1 + 2*ceiling(rad.old.pixels)

# plot
aplot(stamp_size, rlim_size/stamp_size, pch=".", log="y")


# plot
aplot(stamp_size, rlim_size.old/stamp_size, pch=".", log="y")




#stamp_size = 1 + stampextra + 2*ceiling(sersic.mu2r(mu=mulim, mag=dat[,"MAG_AUTO"]+27, n=n, re=dat[,"FLUX_RADIUS"], e=dat[,"ELLIPTICITY"])) # pixels



