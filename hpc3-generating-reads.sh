#! /bin/bash

#SBATCH --job-name=simit
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=3G

simit_script="/pub/jenyuw/Software/Sim-it-Sim-it1.3.4"
ref="/pub/jenyuw/Eval-sv-temp/reference/GCF_000001215.4_Release_6_plus_ISO1_MT_genomic.fna"
sim_raw="/pub/jenyuw/Eval-sv-temp/sim-raw"

nT=$SLURM_CPUS_PER_TASK

line_num=`expr $SLURM_ARRAY_TASK_ID + 1`
echo $line_num
line=`head -n ${line_num} ${sim_raw}/input.value.csv |tail -n 1`

module load perl/5.34.1

line=`head -n $i ${sim_raw}/input.value.csv |tail -n 1`
echo $line
read_type=`echo ${line}|gawk -F "," '{print $1}'`
depth=`echo ${line}|gawk -F "," '{print $2}'`
med_L=`echo ${line}|gawk -F "," '{print $3}'`
r_range=`echo ${line}|gawk -F "," '{print $4}'`
accuracy=`echo ${line}|gawk -F "," '{print $5}'`
err_profile=`echo ${line}|gawk -F "," '{print $6}'`
prj_name=`echo ${line}|gawk -F "," '{print $7}'`


echo -e "`<${sim_raw}/config.template`"|sed ' s@${read_type}@'"$read_type"'@ ; s@${depth}@'"$depth"'@ ; s@${med_L}@'"$med_L"'@ ; s@${r_range}@'"$r_range"'@ ; s@${accuracy}@'"$accuracy"'@ ; s@${err_profile}@'"$err_profile"'@ ; s@${prj_name}@'"$prj_name"'@ ' |\
sed 's@${ref}@'"$ref"'@ ; s@${nT}@'"$nT"'@; s@@@' >${sim_raw}/config.real-$SLURM_ARRAY_TASK_ID

perl ${simit_script}/Sim-it1.3.4.pl -c ${sim_raw}/config.real-$SLURM_ARRAY_TASK_ID -o ${sim_raw}


error_profile_PB_RS2.txt
error_profile_PB_Sequel_CCS_hifi.txt
error_profile_ONT.txt
error_profile_PB_Sequel2.txt