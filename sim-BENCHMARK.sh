#! /bin/bash

#SBATCH --job-name=benchmark
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=6G

source ~/.bashrc
sim_raw="/dfs7/jje/jenyuw/Eval-sv-temp/sim_raw"
ref_genome="/dfs7/jje/jenyuw/Eval-sv-temp/reference/dmel-all-chromosome-r6.49.fasta"
aligned_bam="/dfs7/jje/jenyuw/Eval-sv-temp/results/aligned_bam"
con_SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/consensus_SVs"
tru_bench="/dfs7/jje/jenyuw/Eval-sv-temp/results/truvari_bench"

#ls ${aligned_bam}/*.trimmed-ref.sort.bam >${aligned_bam}/bamlist_1.txt
file=`head -n $SLURM_ARRAY_TASK_ID ${aligned_bam}/bamlist_1.txt |tail -n 1`
name=`basename ${file} | sed s/.trimmed-ref.sort.bam//g`
read_type=`echo ${name} | cut -d '_' -f 1 `

bcftools index -f -t ${sim_raw}/${name}/${name}.sort.vcf.gz
bcftools index -f -t ${con_SVs}/${name}.tru_con.sort.vcf.gz

module load python/3.10.2
truvari bench --pctseq 0 -b ${sim_raw}/${name}/${name}.sort.vcf.gz -c ${con_SVs}/${name}.tru_con.sort.vcf.gz -f ${ref_genome} -o ${tru_bench}/${name}
module unload python/3.10.2