#####
# pie_taxo.r
#####


pie_taxo <- function(mr, taxo, tax_lev=seq_along(taxo), selec_smp=list(1:nrow(mr)),
                     thresh=0.01, cex=0.5, adj=0, mat_lay=NULL, wdt_lay=NULL, hei_lay=NULL,
                     box=F){
  
  ### prepare taxo ----
  taxon <- droplevels(taxo)
  if(length(levels(taxon[,1])) != 1){
    taxon <- cbind.data.frame(life=factor(rep('life', nrow(taxon))), taxon)
  }
  
  # aggregate mr according to the samples groups and taxa
  css <- sapply(seq_along(selec_smp), function(x) {
    if(ncol(mr) > 1){
      colSums(mr[selec_smp[[x]],])
    } else {
      sum(mr[selec_smp[[x]],])
    }
  })
  css <- matrix(css, ncol=length(selec_smp))
  dimnames(css) <- list(names(mr), names(selec_smp))
  
  agg <- aggregate(css, as.list(taxon[tax_lev]), sum)

  # compress small taxon
  col_tax <- which(sapply(agg, is.factor))
  col_sel <- which(sapply(agg, is.numeric)) 
  mct <- max(col_tax)
  lct <- length(col_tax)-1

  # reorganize agg according to the taxonomy
  for(i in rev(col_tax[-1])[-1]){
    agg <- agg[order(agg[,i]),]
  }
  
  for(i in rev(col_tax)[-1]){ # for all tax level but the last
    for(j in unique(agg[,i])){ # for all taxa in a given tax level 
      # get the sub_tax indices
      ind_sub_tax <- which(agg[,i] == j)
      # get the taxon leftover 
      ind_X <- which(agg[ind_sub_tax, i+1] == paste0(j, '_X') | agg[ind_sub_tax, i+1] == paste0(j, 'X'))
      
      if(length(ind_X)){
        
        # supress small taxa
        for(k in ind_sub_tax[-ind_X]){
          for(l in col_sel){
            if(agg[k,l] < sum(agg[,l])*thresh){
              agg[ind_X,l] <- agg[ind_X,l] + agg[k,l]
              agg[k,l] <- 0
            }
          }
        }
        # reorganize the sub tax
        ind_sub_tax <- c(ind_sub_tax[-ind_X], ind_sub_tax[ind_X])
        agg <- agg[c(c(1:nrow(agg))[-ind_sub_tax], ind_sub_tax),]
        
      } else { 
        # create the leftover
        leftov <- ifelse(grepl('_X',j), paste0(j, 'X'), paste0(j, '_X'))
        if(mct-i > 1){
          for(k in (i+2):mct){
            leftov <- c(leftov, paste0(rev(leftov)[1], 'X'))
          }
        }
        leftov <- cbind.data.frame(matrix(c(as.character(unlist(agg[ind_sub_tax[1],1:i])), leftov), nrow=1),
                                   matrix(rep(0, length(col_sel)), nrow=1))
        names(leftov) <- names(agg)
        # supress small taxa
        for(k in ind_sub_tax){
          for(l in col_sel){
            if(agg[k,l] < sum(agg[,l])*thresh){
              leftov[1,l] <- leftov[1,l] + agg[k,l]
              agg[k,l] <- 0
            }
          }
        }
        # reorganize the sub tax
        agg <- rbind.data.frame(agg[c(c(1:nrow(agg))[-ind_sub_tax], ind_sub_tax),], leftov)
        
      }
    }
    # supress empty taxa
    if(length(col_sel) > 1){
      agg <- agg[rowSums(agg[,col_sel]) != 0,]
    } else {
      agg <- agg[agg[,col_sel] != 0,]
    }
    agg <- droplevels(agg)
  }
  
  
  #
  
  ### prepare palette ----
  # pal second level
  lst_pal <- NULL
  uni_2 <- unique(agg[,2])
  lst_pal[[names(agg)[2]]] <- rainbow(length(uni_2))
  lst_pal <- as.list(lst_pal)
  names(lst_pal[[1]]) <- uni_2
  
  # pal inferior levels
  for(i in col_tax[-c(1:2)]){
    pal_sup <- lst_pal[[i-2]]
    for(j in seq_along(pal_sup)){
      j2 <- pal_sup[j]
      if(is.null(names(j2))){
        # names(j2) <- names()
      }
      tax <- unique(agg[agg[,i-1] == names(j2),i])
      j3 <- c(col2rgb(j2)*0.95/255)
      j3 <- rgb(j3[1],j3[2],j3[3])
      pal <- rev(colorRampPalette(c('grey', j3))(length(tax)+1)[-1])
      names(pal) <- tax
      lst_pal[[names(agg)[i]]] <- c(lst_pal[[names(agg)[i]]], pal)      
    }
  }
  #
  
  ### graf ----
  # layout
  lcs <- length(selec_smp)
  if(is.null(mat_lay)){
    mat_lay <- matrix(c(1:lcs, rep(lcs+1,lcs)), ncol=2)  
  }
  if(is.null(wdt_lay)){
    wdt_lay=c(1,(lct-1)*0.65)
  }
  
  layout(mat_lay, width=wdt_lay, height=hei_lay, respect=T)
  
  par(mar=c(0.5,1,1,0.5), oma=c(1,0,1,0), xaxs='i', yaxs='i')
  for(i in col_sel){ # for each sample selection
    
    # plot
    plot.new()
    title(main=names(agg)[i])
    if(box){
      box('plot')
      box('digure',2)
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
        pie <- c(pie, sum(agg[agg[,j] == k,i]))
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
    p <- agg[[i]]/sum(agg[[i]])
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
  
  # x  coord
  xs <- rev(rev(seq(0,1,length.out=ncol(leg)+2)[-1])[-1])
    
  # leg
  par(mar=rep(0,4))
  plot.new()
  
  for(i in seq_along(leg)){
    legend(xs[i], 0.5, leg[,i], xjust=0.5, yjust=0.5, pch=15, col=as.character(pal[,i]), bty='n',
           title=names(leg)[i])
  }
  
  ###
  
  return(agg)
}
