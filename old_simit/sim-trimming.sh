#! /bin/bash

#SBATCH --job-name=qc
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=6G
source ~/.bashrc

sim_raw="/dfs7/jje/jenyuw/Eval-sv-temp/sim_raw"
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
nT=$SLURM_CPUS_PER_TASK

#ls ${sim_raw}/*_60x_*_1/Long_reads_*_HAP1.fasta >${sim_raw}/namelist_1.txt
#Hifi_60x_0.999_1/Long_reads_Hifi_60x_0.999_HAP1.fasta
#ONT_60x_0.9_1/Long_reads_ONT_60x_0.9_HAP1.fasta


file=`head -n $SLURM_ARRAY_TASK_ID ${sim_raw}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 7 `
read_type=`echo ${name} | cut -d '_' -f 1 `
#echo ${file}
#echo ${name}
#echo ${read_type}

conda activate qc
cat ${file} |chopper -l 530 --headcrop 15 --tailcrop 15 |pigz -p ${nT} > ${trimmed}/${name}.trimmed.fastq.gz
conda deactivate

########################################
#THIS keeps failing, skipped
########################################