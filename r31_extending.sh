#!/bin/bash

#SBATCH --job-name="extending"
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=6G


#Patch assemblies

#ntLink for 4 rounds with R1041 and hifi reads

#polishing with hifi reads