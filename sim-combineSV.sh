#! /bin/bash

#SBATCH --job-name=combine
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=6G

source ~/.bashrc

ref_genome="/dfs7/jje/jenyuw/Eval-sv-temp/reference/dmel-all-chromosome-r6.49.fasta"
aligned_bam="/dfs7/jje/jenyuw/Eval-sv-temp/results/aligned_bam"
SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/SVs"
con_SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/consensus_SVs"

nT=$SLURM_CPUS_PER_TASK

#ls ${aligned_bam}/*.trimmed-ref.sort.bam >${aligned_bam}/bamlist_1.txt
file=`head -n $SLURM_ARRAY_TASK_ID ${aligned_bam}/bamlist_1.txt |tail -n 1`
name=`basename ${file} | sed s/.trimmed-ref.sort.bam//g `
read_type=`echo ${name} | cut -d '_' -f 1 `


ls ${SVs}/${name}.*.filtered.vcf
for i in `ls ${SVs}/${name}.*.filtered.vcf`
do
echo ${i}
bgzip -@ ${nT} -f -k ${i}
bcftools index -f -t ${i}.gz
done

bcftools merge -m none ${SVs}/${name}.*.filtered.vcf.gz | bcftools sort -m 2G -O z -o ${con_SVs}/${name}.3.vcf.gz
bcftools index -f -t ${con_SVs}/${name}.3.vcf.gz

#Truvari requires a .tbi index
# truvari can output to stdout
#--intra is only provided later than v4.2 (experimental)
module load python/3.10.2

truvari collapse --intra -k maxqual --sizemax 200000000 \
-i ${con_SVs}/${name}.3.vcf.gz \
-c ${con_SVs}/${name}.tru_collapsed.vcf -f ${ref_genome} |\
bcftools sort -m 2G |bgzip -@ ${nT} > ${con_SVs}/${name}.tru_con.sort.vcf.gz

bcftools index -f -t ${con_SVs}/${name}.tru_con.sort.vcf.gz
module unload python/3.10.2


echo " This is the end!"