#####
# pie_taxo_single.r
#####


pie_taxo_single <- function(pie_taxo, sel_smp, x, y, ray=NULL, cex=0.5, adj=0, last_tax_text=T,
                            info_tax=T, info_perc=T, rshift=0){
  
  agg <- pie_taxo$agg
  lst_pal <- pie_taxo$lst_pal
  
  if(sum(agg[,sel_smp]) != 0){
    
    col_tax <- which(sapply(agg, is.factor))
    col_sel <- which(sapply(agg, is.numeric)) 
    mct <- max(col_tax)
    lct <- length(col_tax)-1
    
    # plot
    # pie rayon
    if(is.null(ray)){
      if(last_tax_text){
        ray <- (1-max(strwidth(agg[[mct]]))*cex*2)/2-adj
      } else {
        ray <- 0.5
      }
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
    if(last_tax_text){
      names(cs) <- agg[[mct]]
    } else {
      names(cs) <- seq_along(agg[[mct]])
    }
    
    for(j in seq_along(cs)){
      if(rad[j] != 0){
        ang <- cs[j]-rad[j]/2
        if(last_tax_text){
          if(info_tax){
            radialtext(names(cs)[j], c(x, y), start=ray+0.01, angle=ang, cex=cex)
          }
          if(info_perc){
            radialtext(paste(round(p[j]*100, digit=1), '%'), c(x, y), middle=ray-ray/lct+shift/5*lct, angle=ang, cex=cex*0.5)
          }
        } else {
          # arctext(paste0('(', names(cs)[j], ') ', round(p[j]*100, digit=1), '%'),
          #            c(x, y), radius=ray-ray/lct+shift/5*lct, middle=ang, cex=cex*0.5)
          if(info_tax | info_perc){
            radialtext(paste(ifelse(info_tax, paste0('(', names(cs)[j], ')'), ''),
                             ifelse(info_perc, paste0(round(p[j]*100, digit=1), '%'), '')),
                       c(x, y), middle=ray-ray/lct+shift/5*lct+rshift, angle=ang, cex=cex*0.5)
            }
        }
      }
    }
  } else {
    print(paste('sel_smp', sel_smp, 'sum agg == 0'))
  }

}
