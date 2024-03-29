#!/bin/sh

num=0
for file in *.in
do
	num=$((num+1));
	i=${file%%.in}
	perl ../main.pl $i.in > $i.res	
	tmp=$(diff -q -b $i.out $i.res)
	if [ -z $1 ] && [ "$1" != "n" ]; then echo "$i: $tmp"; fi
	if [ -n "$tmp" ]; then fail="$fail $i"; fi
done
echo "Number of tests: $num"
if [ -z  "$fail" ]
then
	echo "Ok";
else
	echo "Failed: $fail"
fi
