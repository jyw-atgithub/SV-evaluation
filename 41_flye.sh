#! /bin/bash

#SBATCH --job-name=Flye
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=10G


trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
assemble="/dfs7/jje/jenyuw/Eval-sv-temp/results/assemble"
nT=$SLURM_CPUS_PER_TASK
source ~/.bashrc

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `

declare -A preset_option=(['pacbio2016']='--pacbio-raw' ['nanopore2018']='--nano-raw' ['nanopore2020']='--nano-raw' ['nanopore2023']='--nano-raw')

conda activate assemble
#--pacbio-raw --pacbio-corr --pacbio-hifi --nano-raw --nano-corr --nano-hq --subassemblies is require
flye --threads ${nT} --genome-size 135m ${preset_option[$read_type]} ${file} --out-dir ${assemble}/${name}_flye
conda deactivate