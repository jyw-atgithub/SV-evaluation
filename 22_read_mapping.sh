#!/bin/bash

#SBATCH --job-name=mapping
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=6G

source ~/.bashrc

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
ref_genome="${ref}/r649.rename.fasta" ##REMENBER it is renamed
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
aligned_bam="/dfs7/jje/jenyuw/Eval-sv-temp/results/alignment"

nT=$SLURM_CPUS_PER_TASK

if [[ $SLURM_ARRAY_TASK_ID == 1 ]]
then
ls ${trimmed}/*.trimmed.fastq.gz >${trimmed}/namelist_1.txt
fi

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `

##!!!Importent!! remeber to declare the array##
declare -A mapping_option=(['nanopore2018']='map-ont' ['nanopore2020']='map-ont' ['nanopore2023']='map-ont' ['pacbio2016']='map-pb')

echo "The mapping option is ${mapping_option[$read_type]}"

minimap2 -t ${nT} -a -x ${mapping_option[$read_type]} ${ref_genome} ${file} |\
samtools view -b -h -@ ${nT} |\
samtools sort -m 2G -@ ${nT} -o ${aligned_bam}/${name}.trimmed-ref.sort.bam
# do not use --write-indes. because it produces .csi not .bai
samtools index -@ ${nT} ${aligned_bam}/${name}.trimmed-ref.sort.bam