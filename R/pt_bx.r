#####
# pt_bx.r
#####

pt_bx <- function(x, cex=1, pch=1){
  
  r <- par('cxy')[1]*cex/2
  
  for(i in seq_along(x)){
    
    srt <- sort(x[[i]])
    
    prev <- srt[1]
    points(i, prev, pch=pch, cex=cex)
    
    for(j in seq_along(srt)[-1]){
      cond <- srt[j] < prev+1.5*r
      lt <- length(which(cond))
      if(cond[1]) {
        points(i+r*lt/2, srt[j], pch=pch, cex=cex)
        prev <- c(prev, srt[j])
      } else {
        points(i, srt[j], pch=pch, cex=cex)
        prev <- srt[j]
      }
    }
  }
}

