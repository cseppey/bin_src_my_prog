
#==================
# PRC
#==================

#---
# paramètres graphiques

ct<-0.66

pos_ax2<--0.375; ca<-0.6
cla<-0.75

mgpx<-c(0,-0.1,0)
mgpy<-c(0.9,0.1,0)

pos_lgx<-0.55
pos_lgy<-0.5
clg<-0.7
int_lig_leg<-2.5
mrk_long<--0.01
lwd<-2
seg.len<-5
title.adj<-0.3

cp<-0.5
int_lig_phy<-3.5

fc<-10
inversion_graf<-1 #1 or -1

par(mar=c(2.6,1.75,0.5,2.5), xpd = F, oma = c(0,0,0,0))

rb<-rainbow(24)
cntl_col<-rb[1]
trait_col<-rb[c(3,10)]

#-------------------------------------------------
# modification des fonctions linestack et prc.plot 
#-------------------------------------------------

#---
#linestack2

linestack2<-function (x, labels, cex = 0.8, side = "right", hoff = 2, air = 1.1, fact_correc=0,
                      at = 0, add = FALSE, axis = FALSE, ...) 
{
  if (!missing(labels) && length(labels == 1) && pmatch(labels, 
                                                        c("right", "left"), nomatch = FALSE)) {
    side <- labels
    labels <- NULL
    warning("argument 'label' is deprecated: use 'side'")
  }
  side <- match.arg(side, c("right", "left"))
  x <- drop(x)
  if (!missing(labels) && !is.null(labels)) 
    names(x) <- labels
  else if (is.null(names(x))) 
    names(x) <- rep("", length(x))
  op <- par(xpd = T)
  ord <- order(x)
  x <- x[ord]
  n <- length(x)
  pos <- numeric(n)
  if (!add) {
    plot(pos, x, type = "n", axes = F, xlab = "", ylab = "")
  }
  hoff <- hoff * strwidth("m")
  ht <- air * strheight(names(x), cex = cex)
  mid <- (n + 1)%/%2
  pos[mid-fact_correc] <- x[mid]
  if (n > 1) {
    for (i in (mid-fact_correc + 1):n) {
      pos[i] <- max(x[i], pos[i - 1] + ht[i])
    }
  }
  if (n > 2) {
    for (i in (mid-fact_correc - 1):1) {
      pos[i] <- min(x[i], pos[i + 1] - ht[i])
    }
  }
  segments(at, x[1], at, x[n])
  if (side == "right") {
    text(at + hoff, pos, names(x), pos = 4, cex = cex, offset = 0.2)
    segments(at, x, at + hoff, pos)
  }
  else if (side == "left") {
    text(at - hoff, pos, names(x), pos = 2, cex = cex, offset = 0.2, 
         ...)
    segments(at, x, at - hoff, pos)
  }
  if (axis) 
    axis(if (side == "right") 
      2
         else 4, pos = at, las = 2)
  par(op)
  invisible(pos[order(ord)])
}

#---
# prc.plot

prc.plot <-
  function (x, species = TRUE, select, scaling = 3, axis = 1, type = "l",
            xlab, xaxlab, ylab, ylim, lty = 1:5, col = 1:6, pch, cex = 0.8, 
            legpos, leglab, leg.title, legbty, legcex = 1, ...)
  {
    ## save level names before getting the summary
    levs <- x$terminfo$x<M-F6>lev[[2]]
    x <- summary(x, scaling = scaling, axis = axis)
    oldpar <- par(no.readonly = TRUE)
    on.exit(par(oldpar))
    b <- t(coef(x))*inversion_graf
    xax <- rownames(b)
    if (missing(labels))
    if (missing(xlab))
      xlab <- x$names[1]
    if (missing(xaxlab))
      xaxlab <- xax
    if (missing(ylab))
      ylab <- "Effect"
    if (missing(leglab))
      leglab <- levs
    if (missing(leg.title))
      leg.title <- x$names[2]
    if (missing(legbty))
      legbty <- "o"
    if (!missing(select))
      x$sp <- x$sp[select]
    if (missing(ylim))
      ylim <- if (species)
        range(b, x$sp*inversion_graf, na.rm = TRUE)
    else range(b, na.rm = TRUE)
    if (species) {
      op <- par("mai")
      mrg <- max(strwidth(names(x$sp), cex = cex, units = "in")) +
        strwidth("mmm", cex = cex, units = "in")
      par(mai = c(op[1:3], max(op[4], mrg)))
    }
    if (missing(pch))
      pch <- as.character(1:nrow(b))
    matplot(xax, b, type = type, xlab = xlab, ylab = ylab, ylim = ylim,
            cex = cex, lty = lty, col = col, pch = pch, xaxt="n",
            tck=mrk_lo<M-F6>ng, mgp=mgpy, ...)
    axis(1, at=xax, labels=c("T0","T3","T4","T5","T6","T8","T10","T11"), 
         cex.axis=ca, mgp=mgpx, tck=mrk_long)
    axis(1, at=xax, labels=xaxlab, cex.axis=ca, pos=pos_ax2, tick=F )
    
    abline(h = 0, col = cntl_col,lwd=lwd)
    if (species) {
      linestack2(inversion_graf*x$sp, at = par("usr")[2], add = TRUE, hoff = 1,
                 cex = cex, air=int_lig_phy, fact_correc=fc, ...)
      rug(x$sp*inversion_graf, side = 4)
    }
    if (missing(legpos)) {
      holes <- abs(par("usr")[3:4] - range(b, na.rm = TRUE))
      if (holes[1] > holes[2])
        legpos <- "bottomleft"
      else legpos <- "topleft"
    }
    if (!is.na(legpos)) {
      nl <- length(levs)
      pp <- type %in% c("b", "p")
      pl <- type %in% c("b", "l")
      if (length(lty) == 1)
        lty <- rep(lty, nl-1)
      legend(x=pos_lgx, y=pos_lgy, legend = leglab, col = c(cntl_col, col), lwd=lwd,
             lty = if (pl) lty[c(1,1:(nl-1))], y.intersp=int_lig_leg, yjust=0,
             pch = if (pp) pch, cex = legcex, title = leg.title, bty = legbty, 
             seg.len=seg.len, title.adj=title.adj)
    }
    invisible()
  }

#--------------------------
# création du graphique PRC
#--------------------------

#---
# sélection des phylotypes et normalisation Hellinger

m<-read.table("Projets/maitrise/R/input/mat_rep_28_29_bi2",h=T)

m_pres<-m
for(i in 1:ncol(m)){
  for(j in 1:nrow(m)){
    if(m_pres[j,i]<=3){
      m_pres[j,i]<-0
    }
    else{
      m_pres[j,i]<-1
    }
  }
}

seuil_pres<-10
sch_int<-which(colSums(m_pres)>=seuil_pres)

m<-m[,sch_int]

m<-m[c(1,1,1,2,2,2,3,3,3,4:nrow(m)),]

m.hel<-decostand(m,"hellinger")

#---
# établissement des facteurs

v<-read.table("Projets/maitrise/R/input/variables", h=T)
jcumu<-unique(v$jour_cumu)
jcumu<-paste("(",jcumu,")",sep="")

temps<-gl(8, 9, labels=c(0:7))

traits<-factor(rep(c("C", "P", "F"), 24))

#---
# création du model prc et du graphique

# m.prc<-prc(var_tot[,c(1,2,7)], traits, temps)
m.prc<-prc(m.hel, traits, temps)

prc.plot(m.prc, cex=cp, col=trait_col, lty=c(1,1), lwd=lwd,
         xaxlab=jcumu, xlab="", ylab="Effect",
         leglab=c("Control","Fake pig", "Pig"), leg.title="Treatments", legbty="n",
         legcex=clg, cex.main=ct, cex.axis=ca, cex.lab=cla)












