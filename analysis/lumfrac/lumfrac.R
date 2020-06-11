#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# data
dat = readRDS("../datacollect/skydata.rds")

# definitions
ordera = c(1,5,3,7)
orderb = c(2,6,4,8)
lfA = list(dat$lumfrac50all[,ordera])[[1]]
lfB = list(dat$lumfrac50big[,ordera])[[1]]
lfAlo = list(dat$lumfrac25all[,ordera])[[1]]
lfAhi = list(dat$lumfrac75all[,ordera])[[1]]
lfBlo = list(dat$lumfrac25big[,ordera])[[1]]
lfBhi = list(dat$lumfrac75big[,ordera])[[1]]
pdfname = "lumfrac.pdf"

# par
cex = 1.5
lwd = 1.5
metpch = c(0,3,2,1,4,8,6,5,10,12)
metcol = c(2,2,2,2,3,3,3,3,1,1)

# dev
cairo_pdf(file=pdfname, width=8, height=4.5)

# par
layout(rbind(c(1,3,2,4)))
palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
par("mar"=c(0.25,0.25,0.25,0.25))
par("oma"=c(4,4.5,9.5,2))

# loop
for(j in 1:ncol(lfA)){

    # base plot setup
    if(j==1){labs = c(1,2)}
    if(j==2){labs = c(1)}
    if(j==3){labs = c(1)}
    if(j==4){labs = c(1,4)}
    aplot(NA, xlim=c(0.68,1.3), ylim=c(0.65,1.11), xlab="", ylab="", las=1, side=NA, labels=labs, tick=FALSE, bty="n")
    aaxes(labels=labs, xnmin=1, ynmin=1, las=1, mgp=c(2,0.5,0), xdigits=0)
    if(j%in%c(1,2)){mtext(side=3, line=0.75, text=c("low density simulated regions","high density simulated regions")[j], cex=1, at=par("usr")[2]+0.02)}
    if(j%in%c(1,2)){labtext="exponential"}else{labtext="de Vaucouleurs"}
    label("topleft", lab=colnames(lfA)[j], inset=0.5, outline="white")
    label("bottomright", lab=labtext, inset=0.5, outline="white")
    abox()

    # grid lines
    xx = yy = seq(1, 1, by=0.1)
    for(i in 1:length(xx)){abline(v=xx[i], col="grey75", lty=2)}
    for(i in 1:length(yy)){abline(h=yy[i], col="grey75", lty=2)}

    # error bars
    arrows(x0=lfA[,j], y0=lfBlo[,j], y1=lfBhi[,j], code=3, length=0.025, angle=90, lwd=lwd*0.25, lend=1, col=col2hex(metcol,alpha=0.5), lty=1)
    arrows(y0=lfB[,j], x0=lfAlo[,j], x1=lfAhi[,j], code=3, length=0.025, angle=90, lwd=lwd*0.25, lend=1, col=col2hex(metcol,alpha=0.5), lty=1)

    # points
    apoints(lfA[,j], lfB[,j], pch=metpch, lwd=lwd, cex=cex, lend=1, col=metcol)

}

# labels & legend
par("xpd"=NA)
mtext(side=1, line=2.5, text=bquote(paste("median recovered luminosity fraction ", tilde(mu), " (", mu, " = ", L["out"], " / ", L["in"], ")")), outer=T)
mtext(side=2, line=2, text=bquote(paste(tilde(mu)[25])), outer=T, las=1)
alegend("top", legend=names(dat$files), ncol=4, byrow=T, inset=0.5, outer=TRUE, seg.len=0.8, seg.gap=0.4,  type=setNames(apply(cbind(pch=metpch,lwd=lwd,col=metcol,cex=cex), 1, as.list), rep("p",length(dat$files))), bty="o", cex=1, box.pad=0.25, line.spacing=1.25)

# finish up
graphics.off()


