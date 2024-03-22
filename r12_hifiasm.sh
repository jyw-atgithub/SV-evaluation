#!/bin/bash

#SBATCH --job-name="hifiasm"
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=10G

raw="/dfs7/jje/jenyuw/Eval-sv-temp/raw"
assemble="/dfs7/jje/jenyuw/Eval-sv-temp/results/assemble"

nT=$SLURM_CPUS_PER_TASK

hifiasm -z 20 -t ${nT} --write-paf --primary -l0 -o ${assemble}/iso1_hifi_hifiasm --ul ${raw}/iso1_R1041.fastq.gz ${raw}/iso1_hifi.fastq.gz
