#!/bin/bash

#SBATCH --job-name="extending"
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=6G
raw="/dfs7/jje/jenyuw/Eval-sv-temp/raw"
assemble="/dfs7/jje/jenyuw/Eval-sv-temp/results/assemble"
extending="/dfs7/jje/jenyuw/Eval-sv-temp/results/extending"
nT=$SLURM_CPUS_PER_TASK
source ~/.bashrc

#Patch assemblies
module load python/3.10.2
ragtag.py patch -w -o ${extending} --aligner 'nucmer' \
--nucmer-params "--maxmatch -l 100 -c 500 --threads ${nT}" \
${assemble}/iso1_R1041_flye/assembly.fasta ${assemble}/iso1_hifi_hifiasm-4/assembly.fasta

#ntLink with R1041 and hifi reads
module load anaconda/2022.05
conda activate ntLink
ntLink_rounds run_rounds_gaps target=${extending}/ragtag.patch.fasta reads=${raw}/iso1_hifi.fastq.gz rounds=3 \
k=24 w=250 t=5 soft_mask=True

#/dfs7/jje/jenyuw/Eval-sv-temp/results/extending/ragtag.patch.fasta.k24.w250.z1000.ntLink.3rounds.fa
cp ragtag.patch.fasta.k24.w250.z1000.ntLink.3rounds.fa ${extending}/first.fasta
ntLink_rounds run_rounds_gaps target=${extending}/first.fasta reads=${raw}/iso1_R1041.fastq.gz rounds=3 \
k=24 w=250 t=5 soft_mask=True
/dfs7/jje/jenyuw/Eval-sv-temp/results/extending/first.fasta.k24.w250.z1000.ntLink.3rounds.fa

#polishing with hifi reads, nextPolish
