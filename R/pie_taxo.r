#####
# pie_taxo.r
#####


pie_taxo <- function(mr, taxo, tax_lev=seq_along(taxo), selec_smp=list(1:nrow(mr)), selec_otu=NULL,
                     thresh=0.01, cex=0.5, adj=0, mat_lay=NULL, wdt_lay=NULL, hei_lay=NULL,
                     box=F, show=T, info_perc=T, rshift=0, last_tax_text=T, root=NULL, pal_1_lev=2,
                     pal_ini=rainbow, add_pal=NULL){
  
  ### prepare taxo ----
  taxon <- data.frame(droplevels(taxo[,tax_lev]))
  if(length(levels(taxon[,1])) != 1){
    t <- data.frame(taxon)
    if(ncol(t) == 1){
      names(t) <- names(taxo[,tax_lev])
    }
  } else {
    t <- data.frame(taxon[,-1])
    if(ncol(t) == 1){
      names(t) <- names(taxo[,tax_lev])
    }
  }
  
  taxon <- cbind.data.frame(rare_taxa=factor(rep(paste0('rare_', names(t)[1]), nrow(t))), t)
  
  # perpare selec_smp
  if(is.factor(selec_smp)){
    sel_smp <- list()
    for(i in levels(selec_smp)){
      sel_smp[[i]] <- which(selec_smp == i)
    }
  } else {
    sel_smp <- selec_smp
  }
  
  # aggregate mr according to the samples groups and taxa
  if(is.null(selec_otu)){
    css <- sapply(seq_along(sel_smp), function(x) {
      if(ncol(mr) > 1){
        colSums(as.data.frame(mr)[sel_smp[[x]],])
      } else {
        sum(mr[sel_smp[[x]],])
      }
    })
  } else {
    css <- sapply(seq_along(sel_smp), function(x) {
      if(ncol(mr) > 1){
        cs <- colSums(mr[sel_smp[[x]],])
        ifelse(names(cs) %in% selec_otu[[x]], cs, 0)
      } else {
        sum(mr[sel_smp[[x]],])
      }
    })
  }
  css <- matrix(css, ncol=length(sel_smp))
  dimnames(css) <- list(names(mr), names(sel_smp))
  
  agg <- aggregate(css, as.list(taxon), sum)

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
      # create leftover
      leftov <- ifelse(grepl('_X',j), paste0(j, 'X'), paste0(j, '_X'))
      
      # get the sub_tax indices
      ind_sub_tax <- which(agg[,i] == j)
      # get the taxon leftover 
      ind_X <- which(agg[ind_sub_tax, i+1] == leftov)
      
      if(length(ind_X)){
        
        # supress small taxa
        for(k in ind_sub_tax[-ind_X]){
          for(l in col_sel){
            if(agg[k,l] < sum(agg[,l])*thresh){
              # if there is more then one left over (Eukaryote_X => kata, crypto...)
              if(length(ind_X) == 1){
                agg[ind_X,l] <- agg[ind_X,l] + agg[k,l]
              } else {
                true_ind_X <- which(agg[,i+2] == paste0(leftov, 'X'))
                agg[true_ind_X,l] <- agg[true_ind_X,l] + agg[k,l]
              }
              agg[k,l] <- 0
            }
          }
        }
        # reorganize the sub tax
        ind_sub_tax <- c(ind_sub_tax[-ind_X], ind_sub_tax[ind_X])
        agg <- agg[c(c(1:nrow(agg))[-ind_sub_tax], ind_sub_tax),]
        
      } else { 
        # create the leftover
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
            if(agg[k,l] < sum(agg[,l], leftov[1,l])*thresh){
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
  
  # bring the root at the bottom
  ind_root <- unique(unlist(sapply(agg[,col_tax], function(x) which(grepl(paste0(root, '_*X*'), x) & grepl(paste0(root, '[a-z]'), x) == F))))
  if(is.null(root) == F & length(ind_root)){
    agg <- rbind.data.frame(agg[-ind_root,], agg[ind_root,])
  }
  
  # bring rare at the bottom
  ind_rare <- which(grepl('rare_', agg[,col_tax[lct]]))
  if(length(ind_rare)){
    agg <- rbind.data.frame(agg[-ind_rare,], agg[ind_rare,])
  }
  
  # bring undetermined at the bottom
  ind_undet <- unique(which(agg == 'undetermined', arr.ind=T)[,1])
  if(length(ind_undet)){
    agg <- rbind.data.frame(agg[-ind_undet,], agg[ind_undet,])
  }
  
  # change the leading X by "other"
  agg[,col_tax] <- as.data.frame(lapply(agg[,col_tax], function(x){
    x1 <- sapply(x, function(y){
      z <- as.character(y)
      if(grepl('_X', z)){
        z <- sub('_X+', '', z)
        z <- sub('^', 'other ', z)
      }
      return(z)
    })
    return(as.factor(x1))
  }))
  
  #
  
  ### prepare palette ----
  # pal second level
  lst_pal <- NULL
  uni_2 <- unique(agg[,pal_1_lev])
  lst_pal[[names(agg)[pal_1_lev]]] <- c(pal_ini(length(uni_2)-length(add_pal)), add_pal)
  lst_pal <- as.list(lst_pal)
  names(lst_pal[[1]]) <- uni_2
  
  # pal inferior levels
  for(i in col_tax[-c(1:pal_1_lev)]){
    pal_sup <- lst_pal[[i-pal_1_lev]]
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
  if(show){
    
    # layout
    op <- par(no.readonly=T)
    
    lcs <- length(sel_smp)
    if(is.null(mat_lay)){
      mat_lay <- matrix(c(1:lcs, rep(lcs+1,lcs)), ncol=2)  
    }
    if(is.null(wdt_lay)){
      wdt_lay=c(1,(lct-1)*0.65)
    }
    
    layout(mat_lay, width=wdt_lay, height=hei_lay, respect=T)
    
    par(mar=c(0.5,2,2,0.5), oma=c(1,0,1,0), xaxs='i', yaxs='i')
    for(i in col_sel){ # for each sample selection
      
      # plot
      plot.new()
      title(main=names(agg)[i])
      if(box){
        box('plot')
        box('figure',2)
      }

      if(sum(agg[,i]) != 0){      
        # pie rayon
        if(last_tax_text){
          ray <- (1-max(strwidth(agg[[mct]]))*cex*2)/2-adj
        } else {
          ray <- 0.5
        }
        
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
        if(last_tax_text){
          names(cs) <- agg[[mct]]
        } else {
          names(cs) <- seq_along(agg[[mct]])
        }
        
        for(j in seq_along(cs)){
          perc <- ifelse(info_perc, paste0(' ', round(p[j]*100, digit=1), '%'), '')
          if(rad[j] != 0){
            ang <- cs[j]-rad[j]/2
            if(last_tax_text){
              radialtext(names(cs)[j], c(0.5,0.5), start=ray+0.01, angle=ang, cex=cex)
              radialtext(perc, c(0.5,0.5), middle=ray-shift/5*2+rshift, angle=ang, cex=cex*0.5)
            } else {
              radialtext(paste0('(', names(cs)[j], ')', perc),
                         c(0.5,0.5), middle=ray-shift/5*2+rshift, angle=ang, cex=cex*0.5)
            }
          }
        }
      } else {
        text(0.5,0.5,'sum pie == 0')
      }
      
    }
    
    # legend and pal
    leg <- agg[col_tax[-c(1,ifelse(last_tax_text, mct, 0))]]
    
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
    
    # leg <- as.data.frame(gsub('_X+', '', sapply(leg, function(x) {
    #   y <- as.character(x)
    #   Xs <- grep('_X*', y)
    #   y[Xs] <- gsub('^', 'OTH_', y[Xs])
    #   return(y)
    # })))
    
    # x  coord
    xs <- rev(rev(seq(0,1,length.out=ncol(leg)+1))[-1])
      
    # leg
    par(mar=rep(0,4))
    plot.new()
    
    for(i in seq_along(leg)){
      l <- leg[,i]
      if(last_tax_text == F & i == ncol(leg)){
        l <- paste0('(', 1:nrow(leg), ') ', l)
      }
      legend(xs[i], 0.5, l, xjust=0, yjust=0.5, pch=15, col=as.character(pal[,i]), bty='n',
             title=names(leg)[i])
    }
    
    par(op)
    
  }
  ###
  
  return(list(agg=agg, lst_pal=lst_pal))
}
