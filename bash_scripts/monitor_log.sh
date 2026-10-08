#!/bin/bash

# check file size
# if size exceeds 1M
# make a backup of the file and truncate the file to zero bytes

fdir=~/Documents/searchlog/final
file=~/Documents/searchlog/final/global_found_gold.log
mydate=$(date '+%B %d %Y %R')

# This was for the loop to change file name, but was determined to be unnecessary
result=$(ls -l $fdir | awk '{ print $9 }' | grep -ow "[0-9]" | tr -d '\n')


if [ $(stat -c %s ${file}) -gt "1048576" ] ; then
echo "$mydate: File size exceeds 1M, backing up and truncating" | tee -a ${fdir}/logfile.txt 2>&1
sleep 5
# what do we insert here?
# Instead of running thorough loops, just insert date
cp ${fdir}/${file} ${fdir}/${file}."$mydate"
truncate -s 0 ${fdir}${file}
else
echo "$mydate: File size still under limit" | tee -a ${fdir}/logfile.txt 
fi
