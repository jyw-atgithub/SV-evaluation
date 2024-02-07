#!/bin/bash

bench="/dfs7/jje/jenyuw/Eval-sv-temp/results/benchmark"

printf "">f1_score.txt
for i in `ls ${bench}/*_filtered/summary.json`;
do
name=`echo $i | gawk -F "/" '{print $8}' `
tech=`echo $name | gawk -F "_" '{print $1}'`
coverage=`echo $name | gawk -F "_" '{print $2}'`
caller=`echo $name | gawk -F "." '{print $2}'| gawk -F "_" '{print $1}'`
state=`echo $name | gawk -F "." '{print $2}'| gawk -F "_" '{print $2}'`

f1_score=`cat $i |grep "\"f1\"\: "|tr -d " "`

echo -e "$tech\t$coverage\t$caller\t$state\t${f1_score:5:5}" >> ${bench}/f1_score.txt
done 