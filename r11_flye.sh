#!/bin/bash

#SBATCH --job-name="Flye"
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=10G
raw="/dfs7/jje/jenyuw/Eval-sv-temp/raw"
ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
qc_report="/dfs7/jje/jenyuw/Eval-sv-temp/results/qc_report"
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
assemble="/dfs7/jje/jenyuw/Eval-sv-temp/results/assemble"
source ~/.bashrc
nT=$SLURM_CPUS_PER_TASK

if [[ $SLURM_ARRAY_TASK_ID == 1 ]]
then
ls ${raw}/iso1_{R1041,R941,hifi}.fastq.gz ${raw}/SRR228229{29,30}_R1041.fastq.gz >${raw}/namelist.txt
ls ${raw}/SRR11906525_Sequel.fastq.gz ${raw}/SRR11906526_RSII.fastq.gz >>${raw}/namelist.txt
fi

file=`head -n $SLURM_ARRAY_TASK_ID ${raw}/namelist.txt |tail -n 1`
strain=`echo ${file} | cut -d '/' -f 7 | cut -d '_' -f 1`
read_type=`echo ${file} | cut -d '/' -f 7 | cut -d '_' -f 2|cut -d '.' -f 1`
echo -e ${file} "\n" ${strain} "\n" ${read_type}

#porechop_abi is not required because the adapters seem to be already removed.

##Chopper is not working right now. 
#module load anaconda/2022.05
#. ~/.mycondainit-2022.05
#conda activate qc

#zcat ${file} |chopper -l 560 --headcrop 30 --tailcrop 30 |\
#bgzip -@ ${nT} -c > ${trimmed}/${strain}_${read_type}.trimmed.fastq.gz
#rm ${trimmed}/${strain}_${read_type}.abi.fastq.gz

module load python/3.10.2
declare -A preset_option=(['RSII']='--pacbio-raw' ['Sequel']='--pacbio-raw' ['hifi']='--pacbio-hifi' ['R1041']='--nano-hq' ['R941']='--nano-raw')
echo ${preset_option[$read_type]}

#--pacbio-raw --pacbio-corr --pacbio-hifi --nano-raw --nano-corr --nano-hq --subassemblies is require
flye --threads ${nT} --genome-size 135m ${preset_option[$read_type]} ${file} --out-dir ${assemble}/${strain}_${read_type}_flye