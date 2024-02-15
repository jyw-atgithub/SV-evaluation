#! /bin/bash

#SBATCH --job-name=scaffold
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=6G
#SBATCH --constraint=fastscratch
#--output=???-%A_%a.out

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
ref_genome="${ref}/r649.rename.fasta" ##REMENBER it is renamed
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
assemble="/dfs7/jje/jenyuw/Eval-sv-temp/results/assemble"
scaffold="/dfs7/jje/jenyuw/Eval-sv-temp/results/scaffold"
nT=$SLURM_CPUS_PER_TASK
source ~/.bashrc

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_2.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `
file=${assemble}/${name}_flye/assembly.fasta

#RagTag is installed locally. No conda is needed.
#nucmer of Mummer4 is installed locally. Therefore, nultithreading is supported! <3

module load python/3.10.2
ragtag.py scaffold -r -w --aligner 'nucmer' --nucmer-params "--maxmatch -l 100 -c 500 -t ${nT}" \
-o ${scaffold}/${name} ${ref_genome} ${file}

module unload python/3.10.2