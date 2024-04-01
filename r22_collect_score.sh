#!/bin/bash

busco="/dfs7/jje/jenyuw/Eval-sv-temp/results/busco"
compleasm="/dfs7/jje/jenyuw/Eval-sv-temp/results/compleasm"

printf "" >${busco}/score.txt
for i in `ls ${busco}/*/short_summary.*.txt`
do
    echo $i
    ass=`echo $i|cut -d "/" -f 8`
    c_score=`cat $i | grep "C:" |tr "[" "," | cut -d "," -f 1`
    c_number=`cat $i | grep "Complete BUSCOs"|gawk '{print $1}'`
    sfcd_number=`cat $i | grep "Number of scaffolds"|sed 's/Number of scaffolds//g; s/" "//g' `
    length=`cat $i | grep "Total length"|sed 's/Total length//g; s/" "//g' `
    sfcd_n50=`cat $i | grep "Scaffold N50"|sed 's/Scaffold N50//g; s/" "//g' `
    echo -e ${ass} "\t" ${c_score} "\t" ${c_number} "\t" $sfcd_number "\t" $length "\t" $sfcd_n50 >> ${busco}/score.txt
done

printf "" >${compleasm}/score.txt
for i in `ls ${compleasm}/*/summary.txt`
do
    echo $i
    ass=`echo $i|cut -d "/" -f 8`
    s_score=`cat $i | grep "S:" |tr -d " " | cut -d "," -f 1`
    s_number=`cat $i | grep "S:" |tr -d " " | cut -d "," -f 2`
    d_score=`cat $i | grep "D:" |tr -d " " | cut -d "," -f 1`
    d_number=`cat $i | grep "D:" |tr -d " " | cut -d "," -f 2`
    echo -e ${ass} "\t" ${s_score} "\t" ${s_number} "\t" ${d_score} "\t" ${d_number}>> ${compleasm}/score.txt
done