#! /bin/bash

wd=$PWD

cd $HOME/Language/LaTeX/biblio/

./truc.pl

cd $wd

prefix=${1%.*}

if [ -n "$prefix" ]	
then
  find $prefix* -type f |
  grep -Pv ".tex|.Rnw|$prefix-" |
  xargs rm -f

  if [ "$2" == 'bibpdf' ]
  then
    latex $prefix.tex
    latex $prefix.tex
    bibtex $prefix.aux
    latex $prefix.tex
    latex $prefix.tex
    dvips $prefix.dvi -o $prefix.ps
    ps2pdf -dAutoRotatePages=/None $prefix.ps
    #ps2pdf $prefix.ps
    evince $prefix.pdf
  elif [ "$2" == 'bibps' ]
  then
    latex $prefix.tex
    latex $prefix.tex
    bibtex $prefix.aux
    latex $prefix.tex
    latex $prefix.tex
    dvips $prefix.dvi -o $prefix.ps
    evince $prefix.ps
  elif [ "$2" == 'pdf' ]
  then
    latex $prefix.tex
    dvips $prefix.dvi -o $prefix.ps
    ps2pdf -dAutoRotatePages=/None $prefix.ps
    #ps2pdf $prefix.ps
    evince $prefix.pdf
  elif [ "$2" == 'ps' ]
  then
    latex $prefix.tex
    dvips $prefix.dvi -o $prefix.ps
    evince $prefix.ps
  else
    echo tu veux que j fasse quoi?
  fi

else
  echo met un fichier couillon!
fi



