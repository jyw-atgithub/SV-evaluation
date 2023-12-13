#! /bin/bash

#SBATCH --job-name="sor&fil"
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

for i in `ls ${SVs}/${name}.{cutesv,sniffles,SVIM}.vcf 2>>${SVs}/faillist.txt`
do
prog=`basename ${i} | gawk -F "." '{print $3}' `
##Be careful!!! "print $3"
bgzip -f --keep -@ ${nT} ${i}
# Only the vcf from SVIM is not sorted while others are sorted. We sort all because of convenience.
bcftools sort --write-index --max-mem 2G -O z -o ${SVs}/${name}.${prog}.sort.vcf.gz ${i}.gz
#tabix -f -p vcf ${SVs}/${name}.${prog}.sort.vcf.gz #no need, because "bcftools sort --write-index" generate .csi index

bcftools view --threads ${nT} -r 2L,2R,3L,3R,4,X,Y \
-i 'QUAL >= 10 && FILTER = "PASS"'  -O v -o - ${SVs}/${name}.${prog}.sort.vcf.gz |\
sed 's/DUP_TANDEM/DUP/g; s/DUP:TANDEM/DUP/g; s/DUP_INT/DUP/g; s/DUP:INT/DUP/g' |\
bcftools view --threads ${nT} -O v -o ${SVs}/${name}.${prog}.filtered.vcf
#bgzip -f -dk ${SVs}/${name}.${prog}.filtered.vcf.gz

rm ${SVs}/${name}.${prog}.sort.vcf.gz
rm ${SVs}/${name}.${prog}.sort.vcf.gz.csi
done

echo "This is the end!"
