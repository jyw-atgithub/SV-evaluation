#!/bin/bash

#SBATCH --job-name=reads
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1-13
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=6G

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
sim="/dfs7/jje/jenyuw/Eval-sv-temp/simulation"
nT=$SLURM_CPUS_PER_TASK

module load python/3.8.0

parameter=`head -n $SLURM_ARRAY_TASK_ID ${sim}/parameter.tsv | tail -n 1`
model=`echo $parameter | gawk '{print $1}'`
coverage=`echo $parameter | gawk '{print $2}'`
l_mean=`echo $parameter | gawk '{print $3}'`
l_stdev=`echo $parameter | gawk '{print $4}'`

#coverage=`expr $SLURM_ARRAY_TASK_ID \* 10`
echo "model is $model"
echo "coverage is $coverage %"

if [[ ${model} != "Hifi" ]]
then
###This setting is good for *noisy* reads. NOT for Hifi reads.
VISOR LASeR -g ${ref}/r649.rename.fasta -s ${sim}/hap_1 -b ${sim}/reads.simple.bed -o ${model}_${coverage}_1 \
--tag --fastq --compress \
--threads ${nT} \
--coverage ${coverage}  --read_type pacbio \
--length_mean ${l_mean} --length_stdev ${l_stdev} \
--identity_min 90 --identity_max 95 --identity_stdev 4 \
--error_model ${model} --qscore_model ${model} --junk_reads 0.02 \
--glitches_rate 10000 --glitches_size 25 --glitches_skip 25
#glitches_rate 越小代表越糟糕
fi

module unload python/3.8.0