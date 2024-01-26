#!/bin/bash

simit_script="/home/jenyuw/Software/Sim-it-Sim-it1.3.4"
ref="/home/jenyuw/Eval-SV/reference/GCF_000001215.4_Release_6_plus_ISO1_MT_genomic.fna"
sim_raw="/home/jenyuw/Eval-SV/sim-raw"
nT=16

vcf_input=${sim_raw}/TRA.vcf

## for no reason tab (/t) separation does NOT work. So, I used ","
for k in {1..3}
do 
    for i in {2..4}
    do 
    echo $i
    line=`head -n $i ${sim_raw}/input.value.csv |tail -n 1`
    echo $line
    read_type=`echo ${line}|gawk -F "," '{print $1}'`
    depth=`echo ${line}|gawk -F "," '{print $2}'`
    med_L=`echo ${line}|gawk -F "," '{print $3}'`
    r_range=`echo ${line}|gawk -F "," '{print $4}'`
    accuracy=`echo ${line}|gawk -F "," '{print $5}'`
    err_profile=`echo ${line}|gawk -F "," '{print $6}'`
    prj_name=`echo ${line}|gawk -F "," '{print $7}'`

    echo -e "`<${sim_raw}/config.template`" |\
    sed ' s@${read_type}@'"$read_type"'@ ; s@${depth}@'"$depth"'@ ; s@${med_L}@'"$med_L"'@ ; s@${r_range}@'"$r_range"'@ ; s@${accuracy}@'"$accuracy"'@ ; s@${err_profile}@'"$err_profile"'@ ; s@${prj_name}@'"${prj_name}_${k}"'@ ' |\
    sed 's@${ref}@'"$ref"'@ ; s@${nT}@'"$nT"'@; s@@@' |\
    sed 's@${vcf_input}@'"$vcf_input"'@' >${sim_raw}/config.real.${i}.${k}
    time perl ${simit_script}/Sim-it1.3.4.pl -c ${sim_raw}/config.real.${i}.${k} -o ${sim_raw}/${prj_name}_${k}
    done 
done 