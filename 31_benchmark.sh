#!/bin/bash

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
ref_genome="${ref}/r649.rename.fasta" ##REMENBER it is renamed
sim="/dfs7/jje/jenyuw/Eval-sv-temp/simulation"
bench="/dfs7/jje/jenyuw/Eval-sv-temp/results/benchmark"
SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/SVs"
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"

source ~/.bashrc

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `

#create the vcf for simulated true set. Only once
#python3 convertvcf.py ${ref_genome} ${sim}/HACk.random.bed ${sim}/HACk.random.vcf
#bcftools sort ${sim}/HACk.random.vcf|bgzip -@ 4 -c > ${sim}/HACk.random.vcf.gz
#bcftools index -t ${sim}/HACk.random.vcf.gz

bcftools sort ${SVs}/nanopore2018_100_1.cutesv.vcf |bgzip -@ 4 -c > ${SVs}/nanopore2018_100_1.cutesv.vcf.gz
bcftools index -t ${SVs}/nanopore2018_100_1.cutesv.vcf.gz

bcftools sort ${SVs}/nanopore2018_100_1.sniffles.vcf |bgzip -@ 4 -c > ${SVs}/nanopore2018_100_1.sniffles.vcf.gz
bcftools index -t ${SVs}/nanopore2018_100_1.sniffles.vcf.gz

truvari bench -b ${sim}/base.vcf.gz -c ${SVs}/nanopore2018_100_1.cutesv.vcf.gz -o ${bench}/nanopore2018_100_1.cutesv \
--pctseq 0 --sizemax 10000000

truvari bench -b ${sim}/base.vcf.gz -c ${SVs}/nanopore2018_100_1.sniffles.vcf.gz -o ${bench}/nanopore2018_100_1.sniffles \
--pctseq 0 --sizemax 10000000
#######################################################
bcftools sort ${SVs}/nanopore2018_100_1.svimASM-asm.vcf |bgzip -@ 4 -c > ${SVs}/nanopore2018_100_1.svimASM-asm.vcf.gz
bcftools index -t ${SVs}/nanopore2018_100_1.svimASM-asm.vcf.gz

bcftools sort ${SVs}/nanopore2018_100_1.svimASM-asm5.vcf |bgzip -@ 4 -c > ${SVs}/nanopore2018_100_1.svimASM-asm5.vcf.gz
bcftools index -t ${SVs}/nanopore2018_100_1.svimASM-asm5.vcf.gz

bcftools sort ${SVs}/nanopore2018_100_1.svimASM-scfd.vcf |bgzip -@ 4 -c > ${SVs}/nanopore2018_100_1.svimASM-scfd.vcf.gz
bcftools index -t ${SVs}/nanopore2018_100_1.svimASM-scfd.vcf.gz


truvari bench -b ${sim}/base.vcf.gz -c ${SVs}/nanopore2018_100_1.svimASM-asm.vcf.gz -o ${bench}/nanopore2018_100_1.svimASM-asm \
--pctseq 0 --sizemax 10000000

truvari bench -b ${sim}/base.vcf.gz -c ${SVs}/nanopore2018_100_1.svimASM-asm5.vcf.gz -o ${bench}/nanopore2018_100_1.svimASM-asm5 \
--pctseq 0 --sizemax 10000000

truvari bench -b ${sim}/base.vcf.gz -c ${SVs}/nanopore2018_100_1.svimASM-scfd.vcf.gz -o ${bench}/nanopore2018_100_1.svimASM-scfd \
--pctseq 0 --sizemax 10000000

########################################################

truvari bench -b ${sim}/base.vcf.gz -c ${SVs}/nanopore2018_10_1.mumco-asm.good.sort.vcf.gz -o ${bench}/nanopore2018_10_1.mumco-asm \
--pctseq 0 --sizemax 10000000

truvari bench -b ${sim}/base.vcf.gz -c ${SVs}/nanopore2018_10_1.mumco-scfd.good.sort.vcf.gz -o ${bench}/nanopore2018_10_1.mumco-scfd \
--pctseq 0 --sizemax 10000000

truvari bench -b ${sim}/base.vcf.gz -c ${SVs}/nanopore2018_100_1.mumco.good.sort.vcf.gz -o ${bench}/nanopore2018_100_1.mumco \
--pctseq 0 --sizemax 10000000

########################################################

truvari bench -b ${sim}/base.vcf.gz -c ${SVs}/nanopore2018_100_1.svmu.vcf.gz -o ${bench}/nanopore2018_100_1.svmu \
--pctseq 0 --sizemax 10000000