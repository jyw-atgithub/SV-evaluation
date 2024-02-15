#!/bin/bash

#SBATCH --job-name=profile
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=6G

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
sim="/dfs7/jje/jenyuw/Eval-sv-temp/simulation"
nT=$SLURM_CPUS_PER_TASK

module load python/3.8.0

module unload python/3.8.0