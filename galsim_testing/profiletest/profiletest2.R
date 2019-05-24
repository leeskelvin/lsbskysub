#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
e = c(0,0.3,0.5,0.7,0.9)
Ie = 100
n = 1
a = 15

# loop
Irs1 = Irs2 = sum1 = sum2 = {}
for(i in 1:length(e)){
    
    # update feedmes
    config1 = readLines("galfit.config")
    myline = grep("axis ratio", config1)
    config1[myline] = paste0(" 9) ", 1-e[i], " 0 # axis ratio")
    cat(config1, file="galfit.config", sep="\n")
    config2 = readLines("imfit.config")
    myline = grep("ell", config2)
    config2[myline] = paste0("ell     ", e[i])
    cat(config2, file="imfit.config", sep="\n")
    
    # run software
    system("~/software/galfit/galfit galfit.config")
    system("~/software/imfit/makeimage -nrows 201 -ncols 201 imfit.config --output imfit.fits")
    
    # data
    dat1 = read.fitsim("galfit.fits")
    dat2 = read.fitsim("imfit.fits")
    Irs1 = c(Irs1, list(dat1[101:201,101]))
    Irs2 = c(Irs2, list(dat2[101:201,101]))
    sum1 = c(sum1, sum(dat1))
    sum2 = c(sum2, sum(dat2))
    
}


# par
lwd = 3

# plot
aplot(Irs1[[1]], log="y", type="l", col=1, lwd=lwd)
lines(Irs1[[5]], col=2, lty=2, lwd=lwd)

lines(Irs2[[1]]+1, col=3, lwd=lwd)
lines(Irs2[[5]]+1, col=4, lty=2, lwd=lwd)

lines(sersic.Ixy(x=0:101,y=0,Ie=Ie,n=n,a=a,e=e[1],pa=0)-1, col=5, lwd=lwd)
lines(sersic.Ixy(x=0:101,y=0,Ie=Ie,n=n,a=a,e=e[5],pa=0)-1, col=6, lty=2, lwd=lwd)

lines(sersic.Ir(r=0:101, Ie=Ie, n=n, a=a)-2, col=7, lwd=lwd)



# par
lwd = 5

# plot
aplot(sum1, type="l", col=1, lwd=lwd, lty=1)
lines(sum2, type="l", col=2, lwd=lwd, lty=2)
lines(sersic.Ltot(Ie=Ie,n=n,a=a,e=e), col=3, lwd=lwd, lty=3)



# par
lwd = 5
aplot(sersic.Lr(r=1:100, Ie=Ie, n=n, a=a, e=e[1]), type="l", lwd=lwd, col=1)
abline(h=sum1[1], lwd=lwd, lty=2, col=1)

lines(sersic.Lr(r=1:100, Ie=Ie, n=n, a=a, e=e[2]), lwd=lwd, col=2)
abline(h=sum1[2], lwd=lwd, lty=2, col=2)

lines(sersic.Lr(r=1:100, Ie=Ie, n=n, a=a, e=e[3]), lwd=lwd, col=3)
abline(h=sum1[3], lwd=lwd, lty=2, col=3)

lines(sersic.Lr(r=1:100, Ie=Ie, n=n, a=a, e=e[4]), lwd=lwd, col=4)
abline(h=sum1[4], lwd=lwd, lty=2, col=4)

lines(sersic.Lr(r=1:100, Ie=Ie, n=n, a=a, e=e[5]), lwd=lwd, col=5)
abline(h=sum1[5], lwd=lwd, lty=2, col=5)



# par
imfitdat = c(Irs2[[1]][1],Irs2[[2]][1],Irs2[[3]][1],Irs2[[4]][1],Irs2[[5]][1])
astrodat = c(
    sersic2d(size=11, Ie=Ie, n=n, a=a, e=e[1], pa=0, discrete=T)[6,6]
    ,sersic2d(size=11, Ie=Ie, n=n, a=a, e=e[2], pa=0, discrete=T)[6,6]
    ,sersic2d(size=11, Ie=Ie, n=n, a=a, e=e[3], pa=0, discrete=T)[6,6]
    ,sersic2d(size=11, Ie=Ie, n=n, a=a, e=e[4], pa=0, discrete=T)[6,6]
    ,sersic2d(size=11, Ie=Ie, n=n, a=a, e=e[5], pa=0, discrete=T)[6,6]
)
lwd = 5

# plot
aplot(imfitdat, lwd=lwd, type="l", col=1)
lines(astrodat, lwd=lwd, col=2, lty=2)





