#!/bin/bash

#SBATCH --job-name=sniffles
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1%1
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=6G

source ~/.bashrc

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
ref_genome="${ref}/r649.rename.fasta" ##REMEMBER it is renamed
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
aligned_bam="/dfs7/jje/jenyuw/Eval-sv-temp/results/alignment"
SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/SVs"

nT=$SLURM_CPUS_PER_TASK

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `
file="${aligned_bam}/${name}.trimmed-ref.sort.bam"

module load python/3.10.2

sniffles --threads ${nT} --allow-overwrite --sample-id ${name}_snif \
--minsupport 4 \
--minsvlen 50 --mapq 20 --min-alignment-length 500 \
--cluster-merge-pos 270 \
--max-del-seq-len 100000 \
--reference ${ref_genome} \
--input ${file} --vcf "${SVs}/${name}.sniffles.vcf"

module unload python/3.10.2

echo "This is the end"