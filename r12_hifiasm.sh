#!/bin/bash

#SBATCH --job-name="hifiasm"
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=2-4
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=10G
#SBATCH --time=3-00:00:00

raw="/dfs7/jje/jenyuw/Eval-sv-temp/raw"
assemble="/dfs7/jje/jenyuw/Eval-sv-temp/results/assemble"

nT=$SLURM_CPUS_PER_TASK

#first test
#mkdir ${assemble}/iso1_hifi_hifiasm-1
#hifiasm -z 20 -t ${nT} --write-paf --primary -o ${assemble}/iso1_hifi_hifiasm --ul ${raw}/iso1_R1041.fastq.gz ${raw}/iso1_hifi.fastq.gz
if [[ $SLURM_ARRAY_TASK_ID == 2 ]]
then
#add the -l 0 option
mkdir ${assemble}/iso1_hifi_hifiasm-2
hifiasm -z 20 -t ${nT} --primary -l 0 -o ${assemble}/iso1_hifi_hifiasm-2/iso1 --ul ${raw}/iso1_R1041.fastq.gz ${raw}/iso1_hifi.fastq.gz
fi
if [[ $SLURM_ARRAY_TASK_ID == 3 ]]
then
#try another ultralong read
mkdir ${assemble}/iso1_hifi_hifiasm-3
hifiasm -z 20 -t ${nT} --primary -l 0 -o ${assemble}/iso1_hifi_hifiasm-3/iso1 --ul ${raw}/iso1_R941.fastq.gz ${raw}/iso1_hifi.fastq.gz
fi
if [[ $SLURM_ARRAY_TASK_ID == 4 ]]
then
#Raising -D or -N to improve the assembly in repetitive regions
mkdir ${assemble}/iso1_hifi_hifiasm-4
hifiasm -z 20 -t ${nT} --primary -l 0 -D 10 -N 240 \
-o ${assemble}/iso1_hifi_hifiasm-4/iso1 --ul ${raw}/iso1_R941.fastq.gz ${raw}/iso1_hifi.fastq.gz
fi

if [[ $SLURM_ARRAY_TASK_ID == 5 ]]
then
#Raising -D or -N to improve the assembly in repetitive regions
mkdir ${assemble}/iso1_hifi_hifiasm-5
hifiasm -z 20 -t ${nT} --primary -l 0 -D 12 -N 250 \
-o ${assemble}/iso1_hifi_hifiasm-5/iso1 --ul ${raw}/iso1_R1041.fastq.gz ${raw}/iso1_hifi.fastq.gz
fi

#awk '/^S/{print ">"$2;print $3}' test.p_ctg.gfa > test.p_ctg.fa

#seqkit stats -j 16 iso1_R1041.fastq.gz iso1_R941.fastq.gz SRR228229{29,30}_R1041.fastq.gz
#file                        format  type   num_seqs         sum_len  min_len   avg_len  max_len
#iso1_R1041.fastq.gz         FASTQ   DNA   5,699,019  84,090,872,093       11  14,755.3  402,418
#iso1_R941.fastq.gz          FASTQ   DNA   4,800,500  72,950,169,460       11  15,196.4  672,718
#SRR22822929_R1041.fastq.gz  FASTQ   DNA   1,937,835  21,140,714,134       11  10,909.5  421,676
#SRR22822930_R1041.fastq.gz  FASTQ   DNA   1,481,121  19,204,298,459       12  12,966.1  451,619
