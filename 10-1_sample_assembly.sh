#!/bin/bash

#SBATCH --job-name=sample.ass
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=6G


raw="/dfs7/jje/jenyuw/Eval-sv-temp/raw"
temp="/dfs7/jje/jenyuw/Eval-sv-temp/raw/sample_assembly"
nT=32

conda activate qc
#remember to use zcat if the file is gzipped
zcat ${raw}/SRR23215010-R1041_ONT.fastq.gz |chopper -l 570 --headcrop 35 --tailcrop 35 |\
pigz -p ${nT} > ${temp}/SRR23215010-R1041_ONT.trimmed.fastq.gz
zcat ${raw}/iso1_hifi.fastq.gz |chopper -l 570 --headcrop 35 --tailcrop 35 |\
pigz -p ${nT} > ${temp}/iso1_hifi.trimmed.fastq.gz
conda deactivate

conda activate assemble
#--pacbio-raw --pacbio-corr --pacbio-hifi --nano-raw --nano-corr --nano-hq --subassemblies is require
flye --threads ${nT} --genome-size 135m --pacbio-hifi ${temp}/iso1_hifi.trimmed.fastq.gz --out-dir ${temp}/iso1_hifi_flye
flye --threads ${nT} --genome-size 135m --nano-hq ${temp}/SRR23215010-R1041_ONT.trimmed.fastq.gz --out-dir ${temp}/SRR23215010-R1041_ONT_flye
conda deactivate