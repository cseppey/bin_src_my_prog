#! /home/seppeyc/bin/Rscript

#####
# aggreg_mr
#####

#---
# telechargement

args <- commandArgs(trailingOnly=T)

mr <- read.table(args[1], h=T)

env <- read.table(args[2], h=T)

agg <- as.numeric(args[4])

ech_commun <- paste(intersect(row.names(env), row.names(mr)), collapse='|') 
mr <- mr[grep(ech_commun, row.names(mr)),]
env <- env[grep(ech_commun, row.names(env)),]

#---
# aggreg

mr_agg <- NULL
if (agg == 0) {

  mr_agg <- t(colSums(mr))
  write.table(mr_agg, args[3], quote=F, sep='\t', col.names=NA)

} else if (agg > 0 & agg <= ncol(env)) {

  mr_agg <- aggregate(mr, list(env[,agg]), sum)
  row.names(mr_agg) <- mr_agg[,1]
  mr_agg <- mr_agg[,-1]
  write.table(mr_agg, args[3], quote=F, sep='\t')

} else {
  print('wrong level of aggregation')
}




