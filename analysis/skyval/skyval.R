#!/usr/bin/Rscript --no-init-file

# setup
require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# data
dat = readRDS("../datacollect/skydata.rds")

# definitions
fn = function(flux){-2.5*log10(flux/(0.168^2))+27}
ordera = c(1,5,3,7)
orderb = c(2,6,4,8)
datmeans = list(dat$skymean[,ordera],dat$skymean[,orderb])
datstds = list(dat$skystd[,ordera],dat$skystd[,orderb])
pdfnames = paste0("skyval-", c("a","b","a5","b5"), ".pdf")
ylimlo = c(30.45,32.5,29.6,32.5)
ylimhi = c(27.70,28.5,27.6,28.5)

# par
cex = 1.5
lwd = 1.5
metpch = c(0,3,2,1,4,8,6,5,10,12)
metcol = c(2,2,2,2,3,3,3,3,1,1)
simsources = paste0("Simulating ", c("All Sources","Bright Only (No EBL)","All","Bright Only (No EBL)"))

# loop
for(i in 1:length(datmeans)){

    # dev
    cairo_pdf(file=pdfnames[i], width=8, height=5.5)

    # par
    layout(rbind(c(1,2),c(3,4)))
    palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
    par("mar"=c(0.25,0.25,0.25,0.25))
    par("oma"=c(5.5,4.5,1.5,4.5))

    # loop
    for(j in 1:ncol(datmeans[[i]])){

        # base plot setup
        if(j==1){labs = c(2)}
        if(j==2){labs = c(4)}
        if(j==3){labs = c(2)}
        if(j==4){labs = c(4)}
        aplot(NA, xlim=c(1-0.25,nrow(datmeans[[1]])+0.25), ylim=c(ylimlo[i],ylimhi[i]), xlab="", ylab="", las=1, side=NA, log="", labels=labs, tick=FALSE, bty="n")
        abline(h=seq(27.5,35,by=0.5), col="grey75", lty=2, lend=1)
        #abline(v=c(0.00001,0.0001,0.001,0.01,0.1,1), col="grey75", lty=2, lend=1)
        aaxes(side=c(2,4), labels=labs, ynmin=1, las=1, mgp=c(2,0.5,0))
        if(j%in%c(1,2)){mtext(side=3, line=0.25, text=c("low density simulated region","high density simulated region")[j], cex=1)}
        if(j%in%c(1,2)){labtext="exponential sources"}else{labtext="de Vaucouleurs sources"}
        label("bottomright", lab=colnames(datmeans[[i]])[j], inset=c(0.75,0.65), outline="white")
        label("bottomleft", lab=labtext, inset=c(0.75,0.65), outline="white")
        abox()

        # points
        ydat = suppressWarnings(fn(datmeans[[i]][,j]))
        ydatlo = suppressWarnings(fn(datmeans[[i]][,j] - (datstds[[i]][,j]) ))
        ydathi = suppressWarnings(fn(datmeans[[i]][,j] + (datstds[[i]][,j]) ))
        if( any(is.na(ydat) | ydat>35) ){ ydat[is.na(ydat) | ydat>35] = par("usr")[3]+0.5 }
        if( any(is.na(ydatlo) | ydatlo>35) ){ ydatlo[is.na(ydatlo) | ydatlo>35] = par("usr")[3]+0.5 }
        if( any(is.na(ydathi) | ydathi>35) ){ ydathi[is.na(ydathi) | ydathi>35] = par("usr")[3]+0.5 }
        for(l in 1:length(ydatlo)){
            suppressWarnings(arrows(x0=l, y0=ydatlo[l], y1=ydathi[l], code=3, length=0.05, angle=90, lwd=lwd*0.75, lend=1, col=col2hex(metcol[l],alpha=1), lty="21"))
        }
        apoints(1:nrow(datmeans[[i]]), ydat, pch=metpch, lwd=lwd, cex=cex, lend=1, col=metcol)
        # if(length(toolow) > 0){
        #     for(k in which(toolow)){
        #         arrows(x0=(1:nrow(datmeans[[i]]))[k], y0=ydat[k], y1=par("usr")[3], lwd=lwd, cex=cex, lend=1, col=metcol[k], length=0.075)
        #     }
        # }

        # if(j <= 2){
        #     par("xpd"=NA)
        #     apoints(1:nrow(datmeans[[i]]), rep((par("usr")[3]+0.275),nrow(datmeans[[i]])), pch=metpch, lwd=lwd, cex=cex, lend=1, col=metcol)
        #     par("xpd"=FALSE)
        # }

    }

    # labels & legend
    par("xpd"=NA)
    #mtext(side=1, line=2, text="sky estimation method", outer=T)
    #mtext(side=3, line=1, text=simsources[i], outer=T)
    mtext(side=2, line=2.5, text=bquote(paste("mean estimated sky level / mag ", arcsec^{-2})), outer=T)
    alegend("bottom", legend=names(dat$files), ncol=4, byrow=T, inset=0.5, outer=TRUE, seg.len=0.8, seg.gap=0.4,  type=setNames(apply(cbind(pch=metpch,lwd=lwd,col=metcol,cex=cex), 1, as.list), rep("p",length(dat$files))), bty="o", cex=0.9, box.pad=0.25, line.spacing=1.25)

    # finish up
    graphics.off()

}

# # print latex tabular data
# print("")
# print("DATMEANS")
# print(round(datmeans[[1]]*1e3,digits=1))
# print(round(datmeans[[2]]*1e3,digits=1))
# print("")
# print("DATSTDS")
# print(round(datstds[[1]]*1e3,digits=1))
# print(round(datstds[[2]]*1e3,digits=1))

colnames(datmeans[[1]]) = substr(colnames(datmeans[[1]]), 4, 7)
colnames(datmeans[[2]]) = substr(colnames(datmeans[[2]]), 4, 7)
colnames(datstds[[1]]) = c("...","...","...","...")
colnames(datstds[[2]]) = c("...","...","...","...")

noquote(datmeans[[1]][,0])

rownames(datmeans[[1]]) = c("",'','','','','','','','','')
rownames(datmeans[[2]]) = c("",'','','','','','','','','')
rownames(datstds[[1]]) = c("",'','','','','','','','','')
rownames(datstds[[2]]) = c("",'','','','','','','','','')

noquote(
cbind(  "$", round((datmeans[[1]]*1e3)[,1,drop=F],digits=1), "\\pm", round((datstds[[1]]*1e3)[,1,drop=F],digits=1), "$ &"
        ,"$", round((datmeans[[1]]*1e3)[,2,drop=F],digits=1), "\\pm", round((datstds[[1]]*1e3)[,2,drop=F],digits=1), "$ &"
        ,"$", round((datmeans[[1]]*1e3)[,3,drop=F],digits=1), "\\pm", round((datstds[[1]]*1e3)[,3,drop=F],digits=1), "$ &"
        ,"$", round((datmeans[[1]]*1e3)[,4,drop=F],digits=1), "\\pm", round((datstds[[1]]*1e3)[,4,drop=F],digits=1), "$"
     )
)

noquote(
cbind(  "$", round((datmeans[[2]]*1e3)[,1,drop=F],digits=1), "\\pm", round((datstds[[2]]*1e3)[,1,drop=F],digits=1), "$ &"
        ,"$", round((datmeans[[2]]*1e3)[,2,drop=F],digits=1), "\\pm", round((datstds[[2]]*1e3)[,2,drop=F],digits=1), "$ &"
        ,"$", round((datmeans[[2]]*1e3)[,3,drop=F],digits=1), "\\pm", round((datstds[[2]]*1e3)[,3,drop=F],digits=1), "$ &"
        ,"$", round((datmeans[[2]]*1e3)[,4,drop=F],digits=1), "\\pm", round((datstds[[2]]*1e3)[,4,drop=F],digits=1), "$"
     )
)


# # merge into 1 PDF
# system(paste("/usr/bin/gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=skyval.pdf skyval-a.pdf skyval-b.pdf"))

