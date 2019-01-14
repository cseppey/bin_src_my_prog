#! /home/seppeyc/bin/Rscript

#####
# taxa_ramove
#####

args <- commandArgs(trailingOnly=T)

mr <- read.table(args[1], h=T)
ass <- read.table(args[2], sep='\t')

taxa <- args[4:length(args)]
regex <- paste(taxa, collapse='|')
mr_sMEP <- mr[,-grep(regex, ass$V4)]

print(paste(ncol(mr)-ncol(mr_sMEP), 'OTU removed'))

write.table(mr_sMEP, args[3], quote=F, sep='\t')
