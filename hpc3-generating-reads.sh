#! /bin/bash

#SBATCH --job-name=simit
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1-3
#SBATCH --cpus-per-task=16  ##Sim-it only supports upto 16 threads
#SBATCH --mem-per-cpu=6G

simit_script="/pub/jenyuw/Software/Sim-it-Sim-it1.3.4"
ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference/rn.fasta"
sim_raw="/dfs7/jje/jenyuw/Eval-sv-temp/sim-raw"

nT=$SLURM_CPUS_PER_TASK

line_num=`expr $SLURM_ARRAY_TASK_ID + 1`
echo $line_num
wc -l ${sim_raw}/input.value.tsv

line=`head -n ${line_num} ${sim_raw}/input.value.tsv |tail -n 1`

echo $line
read_type=`echo ${line}|gawk '{print $1}'`
depth=`echo ${line}|gawk '{print $2}'`
med_L=`echo ${line}|gawk '{print $3}'`
r_range=`echo ${line}|gawk '{print $4}'`
accuracy=`echo ${line}|gawk '{print $5}'`
err_profile=`echo ${line}|gawk '{print $6}'`
prj_name=`echo ${line}|gawk '{print $7}'`

## Sim-it is fucking annoying. We need to preserve only major chromosomes and rename 2L, 2R, 3L, 3R!!
## 2L --> 11; 2R --> 12; 3L --> 13; 3R --> 14
## X, Y and shromosome 4 are the same.
##$cat long.fasta |sed 's/2L/11/g;s/2R/12/;s/3L/13/;s/3R/14/' >rn.fasta
##seqkit seq -n rn.fasta

cat ${sim_raw}/config.template|sed ' s@${read_type}@'"$read_type"'@ ; s@${depth}@'"$depth"'@ ; s@${med_L}@'"$med_L"'@ ; s@${r_range}@'"$r_range"'@ ; s@${accuracy}@'"$accuracy"'@ ; s@${err_profile}@'"$err_profile"'@ ; s@${prj_name}@'"$prj_name"'@ ' |\
sed 's@${ref}@'"$ref"'@ ; s@${nT}@'"$nT"'@; s@@@' >${sim_raw}/config.real-$SLURM_ARRAY_TASK_ID

module load perl/5.34.1
#mkdir ${sim_raw}/$SLURM_ARRAY_TASK_ID
perl ${simit_script}/Sim-it1.3.4.pl -c ${sim_raw}/config.real-$SLURM_ARRAY_TASK_ID -o ${sim_raw}/${prj_name}_1

module unload perl/5.34.1

#error_profile_PB_RS2.txt
#error_profile_PB_Sequel_CCS_hifi.txt
#error_profile_ONT.txt
#error_profile_PB_Sequel2.txt