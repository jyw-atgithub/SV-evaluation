#! /bin/bash

#SBATCH --job-name=Flye
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=10G
source ~/.bashrc

sim_raw="/dfs7/jje/jenyuw/Eval-sv-temp/sim_raw"
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
assemble="/dfs7/jje/jenyuw/Eval-sv-temp/results/assemble"
nT=$SLURM_CPUS_PER_TASK

#ls ${sim_raw}/*_60x_*_1/Long_reads_*_HAP1.fasta >${sim_raw}/namelist_1.txt
#Hifi_60x_0.999_1/Long_reads_Hifi_60x_0.999_HAP1.fasta
#ONT_60x_0.9_1/Long_reads_ONT_60x_0.9_HAP1.fasta

file=`head -n $SLURM_ARRAY_TASK_ID ${sim_raw}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 7 `
read_type=`echo ${name} | cut -d '_' -f 1 `

declare -A preset_option=(['RSII']='--pacbio-raw' ['Sequel2']='--pacbio-raw' ['ONT']='--nano-raw' ['Hifi']='--pacbio-hifi' ['ONThq']='--nano-hq')
#echo "The read type is ${read_type}"
#echo "preset_option is ${preset_option[$read_type]}"
#echo "--threads $nT --genome-size 135m ${preset_option[$read_type]} ${file} --out-dir ${assemble}/${name}_flye"
conda activate assemble
#--pacbio-raw --pacbio-corr --pacbio-hifi --nano-raw --nano-corr --nano-hq --subassemblies is require
flye --threads ${nT} --genome-size 135m ${preset_option[$read_type]} ${file} --out-dir ${assemble}/${name}_flye
conda deactivate