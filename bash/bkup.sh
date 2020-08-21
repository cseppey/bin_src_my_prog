#!/bin/bash

dir="/media/cseppey/HDD/home_bkup/cseppey_bkup*"
if [ -d $dir ]
then
  rsync -rv ~/* $dir
fi
