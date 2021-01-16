#!/usr/bin/Rscript --no-init-file

# setup
input = "authors.dat"
output = "authors.tex"

# read data
dat = readLines(input)
if(any(dat == "")){dat[dat==""] = "#"}
nodes = c(diff(substr(dat,1,1) != "#"),-1)
names = read.csv(textConnection(dat[(which(nodes>0)[1]+1):(which(nodes<0)[1])]), strip.white=TRUE, comment.char="#", stringsAsFactors=FALSE)
affil = read.table(textConnection(dat[(which(nodes>0)[2]+1):(which(nodes<0)[2])]), strip.white=TRUE, comment.char="#", stringsAsFactors=FALSE, header=TRUE)

# sort by order,surname
names = names[order(names[,"order"],names[,"surname"],names[,"forename"]),]

# loop over each author
nout = {}
afforder = {}
newaff = {}
for(i in 1:nrow(names)){
    
    # sort out affiliations
    ids = as.numeric(strsplit(as.character(names[i,"affil"]),",")[[1]])
    
    # loop over each author affiliation
    for(j in 1:length(ids)){
    
        idpos = which(affil[,"id"]==ids[j])
        
        if(!idpos%in%afforder){
            afforder = c(afforder, idpos)
            newaff = c(newaff, (length(afforder)+0))
        }else{
            newaff = c(newaff, which(afforder==idpos))
        }
        
    }
    myaff = newaff[(length(newaff)-length(ids)+1):length(newaff)]
    
    # build up the name
    name = paste(strsplit(paste(names[i,"forename"], names[i,"surname"]), " +")[[1]], collapse="~")
    if(i < (length(names[,1])-1)){
        name = paste(name, ",", sep="")
    }
    name = paste(name, "$^{", paste(myaff, collapse=","), "}$", sep="")
    if(!is.na(names[i,"email"])){
        if(names[i,"email"]!=""){
            #name = paste(name, "\\thanks{E-mail: \\texttt{", names[i,"email"], "}}", sep="")
            name = paste(name, "\\thanks{E-mail: ", names[i,"email"], "}", sep="")
        }
    }
    if(i==length(names[,1])){
        name = paste("and ", name, sep="")
    }
    
    # combine with name out vector
    nout = c(nout, name)
    
}

# create affil out vector
aout = paste("$^{", 1:length(afforder), "}$", affil[afforder,"address"], "\\\\", sep="")

# return results
basename = paste(strsplit(paste(paste(paste(substr(strsplit(names[1,"forename"], " +")[[1]],1,1)), ".", sep="", collapse=" "), names[1,"surname"]), " +")[[1]], collapse="~")
cat("\\author[", basename, " et al.]{\n\\parbox{\\textwidth}{\n\\raggedright\n", paste(nout,"\n",sep=""), "}\\vspace{0.5cm}\\\\\n\\parbox{\\textwidth}{\n", paste(aout,"\n",sep=""), "}\n\\vspace{-0.75cm}\n}", sep="", file=output)