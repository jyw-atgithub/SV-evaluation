#! /bin/bash

#SBATCH --job-name=reads
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1-10
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=6G

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
sim="/dfs7/jje/jenyuw/Eval-sv-temp/simulation"
nT=$SLURM_CPUS_PER_TASK

cd $sim
module load R/4.2.2
module load python/3.8.0

coverage=`expr $SLURM_ARRAY_TASK_ID \* 10`
echo "coverage is $coverage \%"

#read_type="nanopore" or "pacbio"
VISOR LASeR -g ${ref}/r649.rename.fasta -s ${sim}/hap_1 -b ${sim}/reads.simple.bed -o CLR_${coverage}_1 \
--tag --fastq --compress \
--threads ${nT} \
--coverage ${coverage}  --read_type pacbio \
--length_mean 8500 --length_stdev 6000 \
--identity_min 90 --identity_max 96 --identity_stdev 3 \
--error_model "pacbio2016" --qscore_model "pacbio2016" --junk_reads 0.02 \
--glitches_rate 1000 --glitches_size 25 --glitches_skip 25