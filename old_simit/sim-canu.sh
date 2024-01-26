#! /bin/bash

#SBATCH --job-name=canu
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=60
#SBATCH --mem-per-cpu=6G
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


if [[ ${read_type} == "ONT" ]] || [[ ${read_type} == "ONThq" ]];
then 
canu -p ${name} -d ${assemble}/${name}_canu \
genomeSize=135m \
maxInputCoverage=90 \
minReadLength=500 \
maxThreads=${nT} \
correctedErrorRate=0.105 \
'corMhapOptions=--threshold 0.8 --ordered-sketch-size 1000 --ordered-kmer-size 14' \
useGrid=false \
-raw -nanopore ${file}

elif [[ ${read_type} == "RSII" ]] || [[ ${read_type} == "Sequel2" ]];
then
##For PACBIO Sequel II
canu -p ${name} -d ${assemble}/${name}_canu \
genomeSize=135m \
maxInputCoverage=90 \
minReadLength=500 \
minOverlapLength=500 \
maxThreads=${nT} \
correctedErrorRate=0.035 utgOvlErrorRate=0.065 trimReadsCoverage=2 trimReadsOverlap=500 \
stopOnLowCoverage=2 minInputCoverage=2.5 \
useGrid=false \
-raw -pacbio ${file}

elif [[ ${read_type} == "Hifi" ]]
then
##For PACBIO Sequel II
canu -p ${name} -d ${assemble}/${name}_canu \
genomeSize=135m \
maxInputCoverage=90 \
minReadLength=500 \
maxThreads=${nT} \
useGrid=false \
-pacbio-hifi ${file}
fi

echo "This is the end!!"