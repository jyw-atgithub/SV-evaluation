#!/bin/bash

#SBATCH --job-name=reads
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1-40
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=6G

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
sim="/dfs7/jje/jenyuw/Eval-sv-temp/simulation"
nT=$SLURM_CPUS_PER_TASK

module load python/3.8.0

#create the required bed file for cilmuating the reads
if [[ $SLURM_ARRAY_TASK_ID == 1 ]]
then
#coverage fluctuations (capture bias) value is the 4th column; purity value is the 5th column (100.0 means no contamination)
#in awk: int() returns integer; rand() returns random number between 0 and 1; int(rand()*11)+90 returns 9 to 100
#awk 'OFS=FS="\t"''{print $1, "1", $2, "100.0", "100.0"}' ${sim}/maxdims.tsv > ${sim}/reads.simple.bed #First run
#Do this manually for the second run. We made the reads worse because they were too good at the first time.
awk 'OFS=FS="\t"''{print $1, "1", $2, int(rand()*21)+80, "100.0"}' ${sim}/maxdims.tsv > ${sim}/reads.2.simple.bed #second run
fi

#the parameter.tsv file is created manually by excel.
parameter=`head -n $SLURM_ARRAY_TASK_ID ${sim}/parameter.tsv | tail -n 1`
model=`echo $parameter | gawk '{print $1}'`
coverage=`echo $parameter | gawk '{print $2}'`
l_mean=`echo $parameter | gawk '{print $3}'`
l_stdev=`echo $parameter | gawk '{print $4}'`

bed="reads.2.simple.bed"
#coverage=`expr $SLURM_ARRAY_TASK_ID \* 10`
echo "model is $model"
echo "coverage is $coverage %"
#remember to change the serial number of output folder
if [[ ${model} == "pacbio2016" || ${model} == "nanopore2018" || ${model} == "nanopore2020" ]]
then
###This setting is good for *noisy* reads. NOT for Hifi reads.
VISOR LASeR -g ${ref}/r649.rename.fasta -s ${sim}/hap_1 -b ${sim}/${bed} -o ${model}_${coverage}_2 \
--tag --fastq --compress \
--threads ${nT} \
--coverage ${coverage}  --read_type pacbio \
--length_mean ${l_mean} --length_stdev ${l_stdev} \
--identity_min 90 --identity_max 98 --identity_stdev 5 \
--error_model ${model} --qscore_model ${model} --junk_reads 0.03 \
--glitches_rate 5000 --glitches_size 30 --glitches_skip 30
#--glitches_rate 10000 --glitches_size 25 --glitches_skip 25
#glitches_rate 越小代表越糟糕
elif [[ ${model} == "nanopore2023" ]]
then
VISOR LASeR -g ${ref}/r649.rename.fasta -s ${sim}/hap_1 -b ${sim}/${bed} -o ${model}_${coverage}_2 \
--tag --fastq --compress \
--threads ${nT} \
--coverage ${coverage}  --read_type pacbio \
--length_mean ${l_mean} --length_stdev ${l_stdev} \
--identity_min 95 --identity_max 99 --identity_stdev 2.5 \
--error_model ${model} --qscore_model ${model} --junk_reads 0.03 \
--glitches_rate 5000 --glitches_size 30 --glitches_skip 30
#--glitches_rate 10000 --glitches_size 25 --glitches_skip 25
#glitches_rate 越小代表越糟糕
fi

module unload python/3.8.0