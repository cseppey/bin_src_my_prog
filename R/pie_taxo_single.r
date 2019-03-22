#####
# pie_taxo_single.r
#####


pie_taxo_single <- function(pie_taxo, sel_smp, x, y, ray=NULL, cex=0.5, adj=0){

  agg <- pie_taxo$agg
  lst_pal <- pie_taxo$lst_pal

  col_tax <- which(sapply(agg, is.factor))
  col_sel <- which(sapply(agg, is.numeric)) 
  mct <- max(col_tax)
  lct <- length(col_tax)-1
  
  # plot
  # pie rayon
  if(is.null(ray)){
    ray <- (1-max(strwidth(agg[[mct]]))*cex*2)/2-adj
  }
  r <- ray
  shift <- ray/lct
  
  for(j in rev(col_tax[-1])){ # for each tax lev except the first
    # get the sum of each taxon
    tax <- unique(agg[,j])
    pie <- NULL
    for(k in tax){
      pie <- c(pie, sum(agg[agg[,j] == k,sel_smp]))
    }
    names(pie) <- tax
    pal <- lst_pal[[j-1]]

    # pie
    floating.pie(x, y, pie, radius=r, col=lst_pal[[j-1]][pie != 0], border=NA)
    r <- r-shift
    if(j != 2){
      draw.circle(x, y ,r+shift/5, col='white', border=NA)
    }
    
  }
  
  # rad line 1st tax lev
  cs <- cumsum(pie/sum(pie))*2*pi
  for(j in cs){draw.radial.line(0, ray, c(x, y), angle=j, lwd=0.5)}
  
  # last taxa
  p <- agg[[sel_smp]]/sum(agg[[sel_smp]])
  rad <- p*2*pi
  cs <- cumsum(rad)
  names(cs) <- agg[[mct]]
  for(j in seq_along(cs)){
    if(rad[j] != 0){
      ang <- cs[j]-rad[j]/2
      radialtext(names(cs)[j], c(x, y), start=ray+0.01, angle=ang, cex=cex)
      radialtext(paste(round(p[j]*100, digit=1), '%'), c(x, y), middle=ray-ray/lct+shift/5*3, angle=ang, cex=cex*0.5)
    }
  }

}
