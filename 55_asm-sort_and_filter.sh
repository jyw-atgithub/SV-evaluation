#!/bin/bash

#SBATCH --job-name=asm-filter
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=10G
####SBATCH --constraint=fastscratch

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
ref_genome="${ref}/r649.rename.fasta" ##REMENBER it is renamed
sim="/dfs7/jje/jenyuw/Eval-sv-temp/simulation"
bench="/dfs7/jje/jenyuw/Eval-sv-temp/results/benchmark"
SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/SVs"
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
nT=$SLURM_CPUS_PER_TASK

source ~/.bashrc

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_2.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `

bgzip -f --keep -@ ${nT} ${SVs}/${name}.svimASM.vcf
bcftools sort --write-index --max-mem 4G -O z -o ${SVs}/${name}.svimASM.sort.vcf.gz ${SVs}/${name}.svimASM.vcf.gz

for i in ${SVs}/${name}.svimASM.sort.vcf.gz ${SVs}/${name}.mumco.good.sort.vcf.gz ${SVs}/${name}.svmu.vcf.gz
do
#bgzip -f --keep -@ ${nT} ${i}
#bcftools sort --write-index --max-mem 4G -O z -o ${i}.sort.gz ${i}.gz
prog=`basename ${i} | gawk -F "." '{print $2}'`
bcftools view --threads ${nT} -r 2L,2R,3L,3R,4,X,Y -i 'FILTER = "PASS"' -O v -o - ${i} |\
bcftools sort --max-mem 4G -O v |\
sed 's/DUP_TANDEM/DUP/g; s/DUP:TANDEM/DUP/g; s/DUP_INT/DUP/g; s/DUP:INT/DUP/g; s/BND/TRA/g' |\
sed 's/ .       PASS/   30      PASS/g' |\
grep -v "NNNNNNNNNNNNNNNNNNNN" |bgzip -@ ${nT} -c > ${SVs}/${name}.${prog}.filtered.vcf.gz
done

###########TO DO: try to remove homopolymers or multiple "N" in the mumco vcf###########
##We only want the DUP and INS from mumco
##Change the quality score of mumco vcf. Better quality for duplication
mv ${SVs}/${name}.mumco.filtered.vcf.gz ${SVs}/${name}.mumco.filtered.ori.vcf.gz
zcat ${SVs}/${name}.mumco.filtered.ori.vcf.gz|grep  "#" |bgzip -@ ${nT} -c > ${SVs}/${name}.mumco.filtered.vcf.gz.header
zcat ${SVs}/${name}.mumco.filtered.ori.vcf.gz|grep -v "#" |gawk -v OFS='\t' '{
    if ($5=="\<DUP\>" || $5=="\<INS\>") 
    {
        print $1,$2,$3,$4,$5,"40",$7,$8,$9,$10
        }
    }'|\
grep -v "NNNNNNNNNNNNNNNNNNNN" |\
bgzip -@ ${nT} -c > ${SVs}/${name}.mumco.filtered.vcf.gz.body
cat ${SVs}/${name}.mumco.filtered.vcf.gz.header ${SVs}/${name}.mumco.filtered.vcf.gz.body > ${SVs}/${name}.mumco.filtered.vcf.gz
rm ${SVs}/${name}.mumco.filtered.vcf.gz.header ${SVs}/${name}.mumco.filtered.vcf.gz.body
#rm ${name}.*.csi
echo "This is the end!"