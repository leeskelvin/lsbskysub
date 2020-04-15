#!/usr/bin/Rscript --no-init-file

# setup
#require("astro", quietly=TRUE)
#palette(c("#000000", "#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#edf8b1", "#7fcdbb", "#2c7fb8"))
set.seed(3125)

# definitions
files = c(  "SExtractor default"="../../source_extraction/sex_default/stats_sex_default.csv"
            ,"SExtractor modified"="../../source_extraction/sex_optimised/stats_sex_optimised.csv"
            ,"SExtractor w. dilated masks"="../../source_extraction/sex_dilated/stats_sex_dilated.csv"
            ,"SExtractor w. modelled masks"="../../source_extraction/sex_modelled/stats_sex_modelled.csv"
            ,"Gnuastro default"="../../source_extraction/gnuastro_default/stats_gnuastro_default.csv"
            ,"Gnuastro modified"="../../source_extraction/gnuastro_optimised/stats_gnuastro_optimised.csv"
            ,"Gnuastro w. dilated masks"="../../source_extraction/gnuastro_dilated/stats_gnuastro_dilated.csv"
            ,"Gnuastro w. modelled masks"="../../source_extraction/gnuastro_modelled/stats_gnuastro_modelled.csv"
            ,"DM stack c. 2018"="../../source_extraction/dmstack_default/stats_dmstack_default.csv"
            ,"DM stack c. 2020"="../../source_extraction/dmstack_optimised/stats_dmstack_optimised.csv"
)
mats = tolower(colnames(read.csv(files[1], stringsAsFactors=FALSE)))
ids = read.csv(files[1], stringsAsFactors=FALSE)[,"ID"]
out = {}
for(i in 1:length(mats)){
    #assign(x=mats[i], value=matrix(NA, nrow=length(files), ncol=length(ids), dimnames=list(names(files),ids)))
    out = c(out, list(matrix(NA, nrow=length(files), ncol=length(ids), dimnames=list(names(files),ids))))
}
names(out) = mats

# data gather
for(i in 1:length(files)){
    dat = read.csv(files[i], stringsAsFactors=FALSE)
    for(j in 1:length(out)){
        coldat = dat[,which(tolower(colnames(dat))==names(out)[j])]
        out[[j]][i,] = coldat
    }
}

# finish up
out = c(files=list(files), out)

# save
saveRDS(out, file="skydata.rds")
