#! /bin/bash

#SBATCH --job-name=sniffles
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=6G

source ~/.bashrc

ref_genome="/dfs7/jje/jenyuw/Eval-sv-temp/reference/dmel-all-chromosome-r6.49.fasta"
aligned_bam="/dfs7/jje/jenyuw/Eval-sv-temp/results/aligned_bam"
SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/SVs"

nT=$SLURM_CPUS_PER_TASK

#ls ${aligned_bam}/*.trimmed-ref.sort.bam >${aligned_bam}/bamlist_1.txt

file=`head -n $SLURM_ARRAY_TASK_ID ${aligned_bam}/bamlist_1.txt |tail -n 1`
name=`basename ${file} | sed s/.trimmed-ref.sort.bam//g `
read_type=`echo ${name} | cut -d '_' -f 1 `

module load python/3.10.2

sniffles --threads ${nT} --allow-overwrite --sample-id ${name}_snif \
--minsupport 10 \
--minsvlen 50 --mapq 20 --min-alignment-length 500 \
--cluster-merge-pos 270 \
--max-del-seq-len 100000 \
--reference ${ref_genome} \
--input ${file} --vcf "${SVs}/${name}.sniffles.vcf"

module unload python/3.10.2

echo "This is the end"