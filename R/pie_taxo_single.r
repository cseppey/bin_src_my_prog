#####
# pie_taxo_single.r
#####


pie_taxo <- function(pie_taxo, sel_smp, box=F){

  agg <- pie_taxo$agg
  lst_pal <- pie_taxo$lst_pal

  col_tax <- which(sapply(agg, is.factor))
  col_sel <- which(sapply(agg, is.numeric)) 
  mct <- max(col_tax)
  lct <- length(col_tax)-1
  
  # plot
  plot.new()
  title(main=names(agg)[sel_smp])
  if(box){
    box('plot')
    box('figure',2)
  }
  
  # pie rayon
  ray <- (1-max(strwidth(agg[[mct]]))*cex*2)/2-adj
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
    floating.pie(0.5,0.5, pie, radius=r, col=lst_pal[[j-1]][pie != 0], border=NA)
    r <- r-shift
    if(j != 2){
      draw.circle(0.5,0.5,r+shift/5, col='white', border=NA)
    }
    
  }
  
  # rad line 1st tax lev
  cs <- cumsum(pie/sum(pie))*2*pi
  for(j in cs){draw.radial.line(0, ray, c(0.5,0.5), angle=j, lwd=0.5)}
  
  # last taxa
  p <- agg[[sel_smp]]/sum(agg[[sel_smp]])
  rad <- p*2*pi
  cs <- cumsum(rad)
  names(cs) <- agg[[mct]]
  for(j in seq_along(cs)){
    if(rad[j] != 0){
      ang <- cs[j]-rad[j]/2
      radialtext(names(cs)[j], c(0.5,0.5), start=ray+0.01, angle=ang, cex=cex)
      radialtext(paste(round(p[j]*100, digit=1), '%'), c(0.5,0.5), middle=ray-ray/lct+shift/5*3, angle=ang, cex=cex*0.5)
    }
  }

}
