#!/bin/bash

#SBATCH --job-name="qc+trim"
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=6G

source ~/.bashrc

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
sim="/dfs7/jje/jenyuw/Eval-sv-temp/simulation"
qc_report="/dfs7/jje/jenyuw/Eval-sv-temp/results/qc_report"
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"

lqc="/pub/jenyuw/Software/LongQC-1.2.0c"
nT=$SLURM_CPUS_PER_TASK

if [[ $SLURM_ARRAY_TASK_ID == 1 ]]
then
ls ${sim}/{nanopore2018,nanopore2020,nanopore2023,pacbio2016}_*_2/r.fq.gz >${sim}/namelist_2.txt
fi

#remember to change the name of filelist!!
file=`head -n $SLURM_ARRAY_TASK_ID ${sim}/namelist_2.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 7 `
read_type=`echo ${name} | cut -d '_' -f 1 `
coverage=`echo ${name} | cut -d '_' -f 2 `
echo ${file}
#echo ${name}
echo ${read_type}
echo ${coverage}

module load python/3.8.0

declare -A preset_option=(['nanopore2018']='ont-ligation' ['nanopore2020']='ont-ligation' ['nanopore2023']='ont-ligation' ['pacbio2016']='pb-rs2')

python ${lqc}/longQC.py sampleqc -p ${nT} -x ${preset_option[$read_type]} -n 6000 \
-s ${name} -o ${qc_report}/${name}_longQC ${file}
#--trim_output ${trimmed}/${name}.qctrimmed.fasta
module unload python/3.8.0

conda activate qc
#remember to use zcat if the file is gzipped
zcat ${file} |chopper -l 558 --headcrop 29 --tailcrop 29 |pigz -p ${nT} > ${trimmed}/${name}.trimmed.fastq.gz
conda deactivate