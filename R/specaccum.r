#! /home/seppeyc/bin/Rscript

require(vegan)

args <- commandArgs(trailingOnly=T)
nb_col <- as.numeric(args[3])

mr <- read.table(args[1], h=T)

if(nb_col > ncol(mr)){
  nb_col = ncol(mr)
}

spc <- specaccum(mr[,1:nb_col])

pdf(args[2])
plot(spc)
dev.off()


