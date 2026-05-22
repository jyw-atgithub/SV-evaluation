#!/bin/bash
#SBATCH --job-name=bench
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=6G

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
ref_genome="${ref}/r649.rename.fasta" ##REMENBER it is renamed
sim="/dfs7/jje/jenyuw/Eval-sv-temp/simulation"
bench="/dfs7/jje/jenyuw/Eval-sv-temp/results/benchmark"
SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/SVs"
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
con_SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/consensus_SVs"
source ~/.bashrc

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_2.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `

module load python/3.10.2

#create the vcf for simulated true set. Only once
#python3 convertvcf.py ${ref_genome} ${sim}/HACk.random.bed ${sim}/HACk.random.vcf
#bcftools sort ${sim}/HACk.random.vcf|bgzip -@ 4 -c > ${sim}/HACk.random.vcf.gz
#bcftools index -t ${sim}/HACk.random.vcf.gz

##benchmark the raw output of mapping-based methods
for i in `ls ${SVs}/${name}.{cutesv,sniffles,SVIM}.vcf.gz`
do
prog=`basename ${i} | gawk -F "." '{print $2}' `
bcftools sort -m 2G -O z -o ${SVs}/${name}.${prog}.sort.vcf.gz ${i}
bcftools index -f -t ${SVs}/${name}.${prog}.sort.vcf.gz
truvari bench -b ${sim}/base.vcf.gz -c ${SVs}/${name}.${prog}.sort.vcf.gz -o ${bench}/${name}.${prog}_raw \
--pctseq 0 --sizemax 10000000
done

##benchmark the filtered output of mapping-based methods
for i in `ls ${SVs}/${name}.{cutesv,sniffles,SVIM}.filtered.vcf.gz`
do
bcftools index -f -t ${i}
prog=`basename ${i} | gawk -F "." '{print $2}' `
truvari bench -b ${sim}/base.vcf.gz -c ${i} -o ${bench}/${name}.${prog}_filtered \
--pctseq 0 --sizemax 10000000
done

##benchmark the combination of mapping-based methods
prog1=cutesv
prog2=sniffles
bcftools index -f -t ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz
truvari bench -b ${sim}/base.vcf.gz -c ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz -o ${bench}/${name}.${prog1}_${prog2} \
--pctseq 0 --sizemax 10000000

prog1=cutesv
prog2=SVIM
bcftools index -f -t ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz
truvari bench -b ${sim}/base.vcf.gz -c ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz -o ${bench}/${name}.${prog1}_${prog2} \
--pctseq 0 --sizemax 10000000

prog1=sniffles
prog2=SVIM
bcftools index -f -t ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz
truvari bench -b ${sim}/base.vcf.gz -c ${con_SVs}/${name}.${prog1}_${prog2}.vcf.gz -o ${bench}/${name}.${prog1}_${prog2} \
--pctseq 0 --sizemax 10000000
#3 callers
bcftools index -f -t ${con_SVs}/${name}.3.vcf.gz
truvari bench -b ${sim}/base.vcf.gz -c ${con_SVs}/${name}.3.vcf.gz -o ${bench}/${name}.3 \
--pctseq 0 --sizemax 10000000

##benchmark the raw output of assembly-based methods
for i in ${SVs}/${name}.svimASM.sort.vcf.gz ${SVs}/${name}.mumco.good.sort.vcf.gz ${SVs}/${name}.svmu.vcf.gz
do
prog=`basename ${i} | gawk -F "." '{print $2}' `
bcftools index -f -t ${i}
truvari bench -b ${sim}/base.vcf.gz -c ${i} -o ${bench}/${name}.${prog}_raw \
--pctseq 0 --sizemax 10000000
done

##benchmark the filtered output of assembly-based methods
for i in ${SVs}/${name}.{svimASM,svmu}.filtered.vcf.gz ${SVs}/${name}.mumco.filtered.ori.vcf.gz
do
prog=`basename ${i} | gawk -F "." '{print $2}' `
bcftools index -f -t ${i}
truvari bench -b ${sim}/base.vcf.gz -c ${i} -o ${bench}/${name}.${prog}_filtered \
--pctseq 0 --sizemax 10000000
done

##benchmark the combination of assembly-based methods
prog1=mumco
prog2=svimASM
bcftools index -f -t ${con_SVs}/${name}.tru.${prog1}_${prog2}.sort.vcf.gz
truvari bench -b ${sim}/base.vcf.gz -c ${con_SVs}/${name}.tru.${prog1}_${prog2}.sort.vcf.gz -o ${bench}/${name}.${prog1}_${prog2} \
--pctseq 0 --sizemax 10000000

module unload python/3.10.2