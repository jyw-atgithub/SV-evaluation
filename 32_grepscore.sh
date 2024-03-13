#!/bin/bash

bench="/dfs7/jje/jenyuw/Eval-sv-temp/results/benchmark"

printf "">${bench}/fp_fn.txt
for i in `ls ${bench}/*2.{sniffles_filtered,cutesv_filtered,mumco_svimASM}/summary.json`;
do
name=`echo $i | gawk -F "/" '{print $8}' `
tech=`echo $name | gawk -F "_" '{print $1}'`
coverage=`echo $name | gawk -F "_" '{print $2}'`
caller=`echo $name | gawk -F "." '{print $2}'`

f1_score=`cat $i |grep "\"f1\"\: " |tr -d " "`
fp=`cat $i |grep "\"FP\"\: " |tr -d " "`
fn=`cat $i |grep "\"FN\"\: " |tr -d " "`
comp_cnt=`cat $i |grep "\"comp cnt\": " |tr -d " "`
echo -e "$tech\t$coverage\t$caller\t${f1_score:5:5}\t${fp:5:3}\t${fn:5:3}\t${comp_cnt:10:5}" |tr -d "," >> ${bench}/fp_fn.txt
done