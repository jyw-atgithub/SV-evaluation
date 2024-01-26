#! /bin/bash

#SBATCH --job-name=svim
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1-5%1
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
#"svim reads"requires samtools, but "svim alignment" does not
##some parameter names are changed. Check the svim alignment --help messages.
svim alignment --sample ${name}_svim \
--min_mapq 20 --min_sv_size 50 \
--max_sv_size 10000000 \
--position_distance_normalizer 900 --cluster_max_distance 0.3 \
${SVs}/${name}_SVIM ${file} ${ref_genome}

cp ${SVs}/${name}_SVIM/variants.vcf ${SVs}/${name}.SVIM.vcf

module unload python/3.10.2

echo "This is the end"