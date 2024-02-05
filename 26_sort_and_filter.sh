#!/bin/bash

#SBATCH --job-name=filter
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=6G

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
ref_genome="${ref}/r649.rename.fasta" ##REMENBER it is renamed
sim="/dfs7/jje/jenyuw/Eval-sv-temp/simulation"
bench="/dfs7/jje/jenyuw/Eval-sv-temp/results/benchmark"
SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/SVs"
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
nT=$SLURM_CPUS_PER_TASK

source ~/.bashrc

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `

for i in `ls ${SVs}/${name}.{cutesv,sniffles,SVIM}.vcf 2>>${SVs}/faillist.txt`
do
prog=`basename ${i} | gawk -F "." '{print $2}' `
##Be careful!!! "print $?"
bgzip -f --keep -@ ${nT} ${i}
# Only the vcf from SVIM is not sorted while others are sorted. We sort all because of convenience.
bcftools sort --write-index --max-mem 2G -O z -o ${SVs}/${name}.${prog}.sort.vcf.gz ${i}.gz

bcftools view --threads ${nT} -r 2L,2R,3L,3R,4,X,Y \
-i 'QUAL >= 20 && FILTER = "PASS"'  -O v -o - ${SVs}/${name}.${prog}.sort.vcf.gz |\
sed 's/DUP_TANDEM/DUP/g; s/DUP:TANDEM/DUP/g; s/DUP_INT/DUP/g; s/DUP:INT/DUP/g' |\
bcftools view --threads ${nT} -O z -o ${SVs}/${name}.${prog}.filtered.vcf.gz
bcftools index -f -t ${SVs}/${name}.${prog}.filtered.vcf.gz

rm ${SVs}/${name}.${prog}.sort.vcf.gz
rm ${SVs}/${name}.${prog}.sort.vcf.gz.csi
done

echo "This is the end!"