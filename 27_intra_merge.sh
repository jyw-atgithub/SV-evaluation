#!/bin/bash

#SBATCH --job-name=intra_merge
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=6G

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
ref_genome="${ref}/r649.rename.fasta" ##REMENBER it is renamed
sim="/dfs7/jje/jenyuw/Eval-sv-temp/simulation"
bench="/dfs7/jje/jenyuw/Eval-sv-temp/results/benchmark"
SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/SVs"
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
con_SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/consensus_SVs"

nT=$SLURM_CPUS_PER_TASK
source ~/.bashrc

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_2.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `

module load python/3.10.2

prog1=cutesv
prog2=sniffles
bcftools merge -m none ${SVs}/${name}.{${prog1},${prog2}}.filtered.vcf.gz |\
bcftools sort -m 2G -O z -o ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz
bcftools index -f -t ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz

truvari collapse --intra -k maxqual --sizemax 200000000 --sizemin 50 \
--refdist 600 --pctseq 0.7 --pctsize 0.7 --pctovl 0 \
-i ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz \
-c ${con_SVs}/collapsed_${name}.${prog1}_${prog2}.vcf.gz |\
bcftools sort -m 2G |bgzip -@ ${nT} > ${con_SVs}/${name}.tru.${prog1}_${prog2}.sort.vcf.gz
bcftools index -f -t ${con_SVs}/${name}.tru.${prog1}_${prog2}.sort.vcf.gz

prog1=cutesv
prog2=SVIM
bcftools merge -m none ${SVs}/${name}.{${prog1},${prog2}}.filtered.vcf.gz |\
bcftools sort -m 2G -O z -o ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz
bcftools index -f -t ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz

truvari collapse --intra -k maxqual --sizemax 200000000 --sizemin 50 \
--refdist 600 --pctseq 0.7 --pctsize 0.7 --pctovl 0 \
-i ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz \
-c ${con_SVs}/collapsed_${name}.${prog1}_${prog2}.vcf.gz |\
bcftools sort -m 2G |bgzip -@ ${nT} > ${con_SVs}/${name}.tru.${prog1}_${prog2}.sort.vcf.gz
bcftools index -f -t ${con_SVs}/${name}.tru.${prog1}_${prog2}.sort.vcf.gz

prog1=sniffles
prog2=SVIM
bcftools merge -m none ${SVs}/${name}.{${prog1},${prog2}}.filtered.vcf.gz |\
bcftools sort -m 2G -O z -o ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz
bcftools index -f -t ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz

truvari collapse --intra -k maxqual --sizemax 200000000 --sizemin 50 \
--refdist 600 --pctseq 0.7 --pctsize 0.7 --pctovl 0 \
-i ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz \
-c ${con_SVs}/collapsed_${name}.${prog1}_${prog2}.vcf.gz |\
bcftools sort -m 2G |bgzip -@ ${nT} > ${con_SVs}/${name}.tru.${prog1}_${prog2}.sort.vcf.gz
bcftools index -f -t ${con_SVs}/${name}.tru.${prog1}_${prog2}.sort.vcf.gz

##Three callers
bcftools merge -m none ${SVs}/${name}.{cutesv,sniffles,SVIM}.filtered.vcf.gz |\
bcftools sort -m 2G -O z -o ${con_SVs}/${name}.3.vcf.gz
bcftools index -f -t ${con_SVs}/${name}.3.vcf.gz

truvari collapse --intra -k maxqual --sizemax 200000000 --sizemin 50 \
--refdist 600 --pctseq 0.7 --pctsize 0.7 --pctovl 0 \
-i ${con_SVs}/${name}.3.vcf.gz \
-c ${con_SVs}/collapsed_${name}.3.vcf.gz |\
bcftools sort -m 2G |bgzip -@ ${nT} > ${con_SVs}/${name}.tru.3.sort.vcf.gz
bcftools index -f -t ${con_SVs}/${name}.tru.3.sort.vcf.gz

module unload python/3.10.2
