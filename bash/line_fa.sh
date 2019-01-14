#! /bin/bash

sed -e 's/\r//' -e 's/\(^>.*\)/%\1%/' $1 |
tr -d '\n' |
sed 's/%>/\n>/g' |
sed 's/%/\n/' |
sed '/^$/d' > $2

echo >> $2
