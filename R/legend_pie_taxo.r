#####
# legend_pie_taxo.r
#####


legend_pie_taxo <- function(pie_taxo, x, y, x_range=1, box=F, cex=1){
  
  agg <- pie_taxo$agg
  lst_pal <- pie_taxo$lst_pal
  
  col_tax <- which(sapply(agg, is.factor))
  col_sel <- which(sapply(agg, is.numeric)) 
  mct <- max(col_tax)
  lct <- length(col_tax)-1
  
  # legend and pal
  leg <- agg[col_tax[-c(1,mct)]]
  
  pal <- as.matrix(leg)
  for(i in 1:nrow(pal)){
    for(j in 1:ncol(pal)){
      pal[i,j] <- lst_pal[[j]][names(lst_pal[[j]]) == pal[i,j]]
    }
  }
  pal <- as.data.frame(pal)
  
  for(i in seq_along(leg)){
    prev <- leg[1,i]
    for(j in seq_along(leg[,i])[-1]){
      if(leg[j,i] == prev){
        leg[j,i] <- NA
        pal[j,i] <- NA
      } else {
        prev <- leg[j,i]
      }
    }
  }
  
  # remove empty taxa
  if(ncol(leg) == 1){
    leg <- na.omit(leg)
    pal <- na.omit(pal)
  } else {
    leg <- leg[apply(is.na(leg), 1, function(x) all(x) == F),]
    pal <- pal[apply(is.na(pal), 1, function(x) all(x) == F),]
  }
  
  # xs
  xr05 <- 0.5*x_range
  xs <- x+seq(-xr05, xr05, length.out=ncol(leg))
  
  # leg
  for(i in seq_along(leg)){
    legend(xs[i], y, leg[,i], xjust=0.5, yjust=0.5, pch=15, col=as.character(pal[,i]), bty='n',
           title=names(leg)[i], cex=cex)
  }
}