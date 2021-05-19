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
        aaxes(side=c(2,4), labels=labs, ynmin=4, las=1, mgp=c(2,0.5,0))
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

# print latex tabular data
oo = c(1,3,2,4,1,3,2,4)
# gainlo = 557.926737435189
# gainhi = 563.915070480379
nJy = 57.543993733715446 / (0.168*0.168)
means = cbind(datmeans[[1]][,oo[1]], datmeans[[1]][,oo[2]], datmeans[[1]][,oo[3]], datmeans[[1]][,oo[4]], datmeans[[2]][,oo[1]], datmeans[[2]][,oo[2]], datmeans[[2]][,oo[3]], datmeans[[2]][,oo[4]])
colnames(means) = c(colnames(datmeans[[1]])[oo[1:4]], colnames(datmeans[[2]])[oo[5:8]])
stds = cbind(datstds[[1]][,oo[1]], datstds[[1]][,oo[2]], datstds[[1]][,oo[3]], datstds[[1]][,oo[4]], datstds[[2]][,oo[1]], datstds[[2]][,oo[2]], datstds[[2]][,oo[3]], datstds[[2]][,oo[4]])
colnames(stds) = c(colnames(datstds[[1]])[oo[1:4]], colnames(datstds[[2]])[oo[5:8]])
for(i in 1:nrow(means)){
    if(i==1){
        cat(paste0("    \\multicolumn{1}{r}{label :} & ", paste0("\\multicolumn{1}{c}{(",colnames(means),")}", collapse=" & "), "\\\\\n    "), file="results.tex")
    }
    if(i==1){cat("\\hline\n    \\SExtractor & & & & & & & & \\\\\n    ", file="results.tex", append=TRUE)}
    if(i==5){cat("\\hline\n    \\Gnuastro & & & & & & & & \\\\\n    ", file="results.tex", append=TRUE)}
    if(i==9){cat("\\hline\n    \\LSSTPs & & & & & & & & \\\\\n    ", file="results.tex", append=TRUE)}
    if(i>=1 & i<=4){frontmatter = strsplit(rownames(means)[i], "SExtractor ")[[1]][2]}
    if(i>=5 & i<=8){frontmatter = strsplit(rownames(means)[i], "Gnuastro ")[[1]][2]}
    # if(i>=9 & i<=10){frontmatter = strsplit(rownames(means)[i], "DM stack ")[[1]][2]}
    if(i==9){frontmatter = '\\DMA'}
    if(i==10){frontmatter = '\\DMB'}
    cat(paste0("\\hspace{25pt}", frontmatter), file="results.tex", append=TRUE)
    for(j in 1:ncol(means)){
        #jgain = ifelse((length(grep("denlo", colnames(means)[j])) > 0), gainlo, gainhi)
        cat(" & ", file="results.tex", append=TRUE)

        cat("$", formatC(means[i,j]*nJy, format='f', digits=1), sep="", file="results.tex", append=TRUE)
        cat("\\pm", file="results.tex", append=TRUE)
        cat(formatC(stds[i,j]*nJy, format='f', digits=1), "$", sep="", file="results.tex", append=TRUE)
    }
    if(j==ncol(means) & i!=nrow(means)){
        cat("\\\\\n    ", file="results.tex", append=TRUE)
    }else if (j==ncol(means)){
        cat("\\\\", file="results.tex", append=TRUE)
    }
}

# print mean binary offset statistics
denlo1a = as.numeric(datmeans[[1]][,"denlo1a"] * nJy)
denlo4a = as.numeric(datmeans[[1]][,"denlo4a"] * nJy)
denlo1b = as.numeric(datmeans[[2]][,"denlo1b"] * nJy)
denlo4b = as.numeric(datmeans[[2]][,"denlo4b"] * nJy)
denhi1a = as.numeric(datmeans[[1]][,"denhi1a"] * nJy)
denhi4a = as.numeric(datmeans[[1]][,"denhi4a"] * nJy)
denhi1b = as.numeric(datmeans[[2]][,"denhi1b"] * nJy)
denhi4b = as.numeric(datmeans[[2]][,"denhi4b"] * nJy)
std_denlo1a = as.numeric(datstds[[1]][,"denlo1a"] * nJy)
std_denlo4a = as.numeric(datstds[[1]][,"denlo4a"] * nJy)
std_denlo1b = as.numeric(datstds[[2]][,"denlo1b"] * nJy)
std_denlo4b = as.numeric(datstds[[2]][,"denlo4b"] * nJy)
std_denhi1a = as.numeric(datstds[[1]][,"denhi1a"] * nJy)
std_denhi4a = as.numeric(datstds[[1]][,"denhi4a"] * nJy)
std_denhi1b = as.numeric(datstds[[2]][,"denhi1b"] * nJy)
std_denhi4b = as.numeric(datstds[[2]][,"denhi4b"] * nJy)
sampa = c(denlo1a, denlo4a, denhi1a, denhi4a)
sampb = c(denlo1b, denlo4b, denhi1b, denhi4b)
#sampstd = c(std_denlo1a, std_denlo4a, std_denhi1a, std_denhi4a)
sampstd = c(std_denlo1b, std_denlo4b, std_denhi1b, std_denhi4b)
sampid = c(rep('denlo1a-denlo1b',10), rep('denlo4a-denlo4b',10), rep('denhi1a-denhi1b',10),rep('denhi4a-denhi4b',10))
denhi = c(denhi1a, denhi4a, denhi1b, denhi4b)
denlo = c(denlo1a, denlo4a, denlo1b, denlo4b)
#denstd = c(std_denhi1a, std_denhi4a, std_denhi1b, std_denhi4b)
denstd = c(std_denlo1a, std_denlo4a, std_denlo1b, std_denlo4b)
denid = c(rep('denhi1a-denlo1a',10), rep('denhi4a-denlo4a',10), rep('denhi1b-denlo1b',10),rep('denhi4b-denlo4b',10))
denhi_a = c(denhi1a, denhi4a)
denlo_a = c(denlo1a, denlo4a)
#denstd_a = c(std_denhi1a, std_denhi4a)
denstd_a = c(std_denlo1a, std_denlo4a)
denid_a = c(rep('denhi1a-denlo1a',10), rep('denhi4a-denlo4a',10))
prof4 = c(denlo4a, denlo4b, denhi4a, denhi4b)
prof1 = c(denlo1a, denlo1b, denhi1a, denhi1b)
#profstd = c(std_denlo4a, std_denlo4b, std_denhi4a, std_denhi4b)
profstd = c(std_denlo1a, std_denlo1b, std_denhi1a, std_denhi1b)
profid = c(rep('denlo4a-denlo1a',10), rep('denlo4b-denlo1b',10), rep('denhi4a-denhi1a',10),rep('denhi4b-denhi1b',10))
prof4_a = c(denlo4a, denhi4a)
prof1_a = c(denlo1a, denhi1a)
#profstd_a = c(std_denlo4a, std_denhi4a)
profstd_a = c(std_denlo1a, std_denhi1a)
profid_a = c(rep('denlo4a-denlo1a',10), rep('denhi4a-denhi1a',10))
refnames = rep(rownames(datmeans[[1]]), times=4)
ndigits = 1
print("")
print(paste(" sample a-b diff mean:", formatC(mean(sampa-sampb),format='f',digits=ndigits)))
print(paste("                  std:", formatC(sd(sampa-sampb),format='f',digits=ndigits)))
print(paste("                  min:", formatC(min(sampa-sampb),format='f',digits=ndigits), refnames[which.min(sampa-sampb)], sampid[which.min(sampa-sampb)]))
print(paste("                  max:", formatC(max(sampa-sampb),format='f',digits=ndigits), refnames[which.max(sampa-sampb)], sampid[which.max(sampa-sampb)]))
print(paste("               mean σ:", formatC(mean((sampa-sampb)/sampstd),format='f',digits=ndigits)))
print(paste("                min σ:", formatC(min((sampa-sampb)/sampstd),format='f',digits=ndigits), refnames[which.min((sampa-sampb)/sampstd)], sampid[which.min((sampa-sampb)/sampstd)]))
print(paste("                max σ:", formatC(max((sampa-sampb)/sampstd),format='f',digits=ndigits), refnames[which.max((sampa-sampb)/sampstd)], sampid[which.max((sampa-sampb)/sampstd)]))
print(paste("                num +:", sum((sampa-sampb)>0), "/", length(denlo)))
print(paste("denlo1a-denlo1b num +:", sum((sampa[1:10]-sampb[1:10])>0), "/ 10"))
print(paste("denlo4a-denlo4b num +:", sum((sampa[11:20]-sampb[11:20])>0), "/ 10"))
print(paste("denhi1a-denhi1b num +:", sum((sampa[21:30]-sampb[21:30])>0), "/ 10"))
print(paste("denhi4a-denhi4b num +:", sum((sampa[31:40]-sampb[31:40])>0), "/ 10"))
print("")
print(paste("  den hi-lo diff mean:", formatC(mean(denhi-denlo),format='f',digits=ndigits)))
print(paste("                  std:", formatC(sd(denhi-denlo),format='f',digits=ndigits)))
print(paste("                  min:", formatC(min(denhi-denlo),format='f',digits=ndigits), refnames[which.min(denhi-denlo)], denid[which.min(denhi-denlo)]))
print(paste("                  max:", formatC(max(denhi-denlo),format='f',digits=ndigits), refnames[which.max(denhi-denlo)], denid[which.max(denhi-denlo)]))
print(paste("               mean σ:", formatC(mean((denhi-denlo)/denstd),format='f',digits=ndigits)))
print(paste("                min σ:", formatC(min((denhi-denlo)/denstd),format='f',digits=ndigits), refnames[which.min((denhi-denlo)/denstd)], denid[which.min((denhi-denlo)/denstd)]))
print(paste("                max σ:", formatC(max((denhi-denlo)/denstd),format='f',digits=ndigits), refnames[which.max((denhi-denlo)/denstd)], denid[which.max((denhi-denlo)/denstd)]))
print(paste("              mean σa:", formatC(mean((denhi_a-denlo_a)/denstd_a),format='f',digits=ndigits)))
print(paste("               min σa:", formatC(min((denhi_a-denlo_a)/denstd_a),format='f',digits=ndigits), refnames[which.min((denhi_a-denlo_a)/denstd_a)], denid_a[which.min((denhi_a-denlo_a)/denstd_a)]))
print(paste("               max σa:", formatC(max((denhi_a-denlo_a)/denstd_a),format='f',digits=ndigits), refnames[which.max((denhi_a-denlo_a)/denstd_a)], denid_a[which.max((denhi_a-denlo_a)/denstd_a)]))
print(paste("                num +:", sum((denhi-denlo)>0), "/", length(denlo)))
print(paste("denhi1a-denlo1a num +:", sum((denhi[1:10]-denlo[1:10])>0), "/ 10"))
print(paste("denhi4a-denlo4a num +:", sum((denhi[11:20]-denlo[11:20])>0), "/ 10"))
print(paste("denhi1b-denlo1b num +:", sum((denhi[21:30]-denlo[21:30])>0), "/ 10"))
print(paste("denhi4b-denlo4b num +:", sum((denhi[31:40]-denlo[31:40])>0), "/ 10"))
print("")
print(paste("profile 4-1 diff mean:", formatC(mean(prof4-prof1),format='f',digits=ndigits)))
print(paste("                  std:", formatC(sd(prof4-prof1),format='f',digits=ndigits)))
print(paste("                  min:", formatC(min(prof4-prof1),format='f',digits=ndigits), refnames[which.min(prof4-prof1)], profid[which.min(prof4-prof1)]))
print(paste("                  max:", formatC(max(prof4-prof1),format='f',digits=ndigits), refnames[which.max(prof4-prof1)], profid[which.max(prof4-prof1)]))
print(paste("               mean σ:", formatC(mean((prof4-prof1)/profstd),format='f',digits=ndigits)))
print(paste("                min σ:", formatC(min((prof4-prof1)/profstd),format='f',digits=ndigits), refnames[which.min((prof4-prof1)/profstd)], profid[which.min((prof4-prof1)/profstd)]))
print(paste("                max σ:", formatC(max((prof4-prof1)/profstd),format='f',digits=ndigits), refnames[which.max((prof4-prof1)/profstd)], profid[which.max((prof4-prof1)/profstd)]))
print(paste("              mean σa:", formatC(mean((prof4_a-prof1_a)/profstd_a),format='f',digits=ndigits)))
print(paste("               min σa:", formatC(min((prof4_a-prof1_a)/profstd_a),format='f',digits=ndigits), refnames[which.min((prof4_a-prof1_a)/profstd_a)], profid_a[which.min((prof4_a-prof1_a)/profstd_a)]))
print(paste("               max σa:", formatC(max((prof4_a-prof1_a)/profstd_a),format='f',digits=ndigits), refnames[which.max((prof4_a-prof1_a)/profstd_a)], profid_a[which.max((prof4_a-prof1_a)/profstd_a)]))
print(paste("                num +:", sum((prof4-prof1)>0), "/", length(denlo)))
print(paste("denlo4a-denlo1a num +:", sum((prof4[1:10]-prof1[1:10])>0), "/ 10"))
print(paste("denlo4b-denlo1b num +:", sum((prof4[11:20]-prof1[11:20])>0), "/ 10"))
print(paste("denhi4a-denhi1a num +:", sum((prof4[21:30]-prof1[21:30])>0), "/ 10"))
print(paste("denhi4b-denhi1b num +:", sum((prof4[31:40]-prof1[31:40])>0), "/ 10"))
print("")

# colnames(datmeans[[1]]) = substr(colnames(datmeans[[1]]), 4, 7)
# colnames(datmeans[[2]]) = substr(colnames(datmeans[[2]]), 4, 7)
# colnames(datstds[[1]]) = c("...","...","...","...")
# colnames(datstds[[2]]) = c("...","...","...","...")

# noquote(datmeans[[1]][,0])

# rownames(datmeans[[1]]) = c("",'','','','','','','','','')
# rownames(datmeans[[2]]) = c("",'','','','','','','','','')
# rownames(datstds[[1]]) = c("",'','','','','','','','','')
# rownames(datstds[[2]]) = c("",'','','','','','','','','')

# cat("$", round((datmeans[[1]]*1e3)[,1,drop=F],digits=1), "\\pm", round((datstds[[1]]*1e3)[,1,drop=F],digits=1), "$ &"
#         ,"$", round((datmeans[[1]]*1e3)[,3,drop=F],digits=1), "\\pm", round((datstds[[1]]*1e3)[,3,drop=F],digits=1), "$ &"
#         ,"$", round((datmeans[[1]]*1e3)[,2,drop=F],digits=1), "\\pm", round((datstds[[1]]*1e3)[,2,drop=F],digits=1), "$ &"
#         ,"$", round((datmeans[[1]]*1e3)[,4,drop=F],digits=1), "\\pm", round((datstds[[1]]*1e3)[,4,drop=F],digits=1), "$"
#      )


# noquote(
# cbind(  "$", round((datmeans[[2]]*1e3)[,1,drop=F],digits=1), "\\pm", round((datstds[[2]]*1e3)[,1,drop=F],digits=1), "$ &"
#         ,"$", round((datmeans[[2]]*1e3)[,3,drop=F],digits=1), "\\pm", round((datstds[[2]]*1e3)[,3,drop=F],digits=1), "$ &"
#         ,"$", round((datmeans[[2]]*1e3)[,2,drop=F],digits=1), "\\pm", round((datstds[[2]]*1e3)[,2,drop=F],digits=1), "$ &"
#         ,"$", round((datmeans[[2]]*1e3)[,4,drop=F],digits=1), "\\pm", round((datstds[[2]]*1e3)[,4,drop=F],digits=1), "$"
#      )
# )

# noquote(
# cbind(  "$", round((datmeans[[1]]*1e3)[,1,drop=F],digits=1), "\\pm", round((datstds[[1]]*1e3)[,1,drop=F],digits=1), "$ &"
#         ,"$", round((datmeans[[1]]*1e3)[,3,drop=F],digits=1), "\\pm", round((datstds[[1]]*1e3)[,3,drop=F],digits=1), "$ &"
#         ,"$", round((datmeans[[1]]*1e3)[,2,drop=F],digits=1), "\\pm", round((datstds[[1]]*1e3)[,2,drop=F],digits=1), "$ &"
#         ,"$", round((datmeans[[1]]*1e3)[,4,drop=F],digits=1), "\\pm", round((datstds[[1]]*1e3)[,4,drop=F],digits=1), "$"
#      )
# )

# noquote(
# cbind(  "$", round((datmeans[[2]]*1e3)[,1,drop=F],digits=1), "\\pm", round((datstds[[2]]*1e3)[,1,drop=F],digits=1), "$ &"
#         ,"$", round((datmeans[[2]]*1e3)[,3,drop=F],digits=1), "\\pm", round((datstds[[2]]*1e3)[,3,drop=F],digits=1), "$ &"
#         ,"$", round((datmeans[[2]]*1e3)[,2,drop=F],digits=1), "\\pm", round((datstds[[2]]*1e3)[,2,drop=F],digits=1), "$ &"
#         ,"$", round((datmeans[[2]]*1e3)[,4,drop=F],digits=1), "\\pm", round((datstds[[2]]*1e3)[,4,drop=F],digits=1), "$"
#      )
# )


# # merge into 1 PDF
# system(paste("/usr/bin/gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=skyval.pdf skyval-a.pdf skyval-b.pdf"))

