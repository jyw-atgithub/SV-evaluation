#! /bin/bash

#SBATCH --job-name=SVIM-asm
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=6G
#SBATCH --constraint=fastscratch

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
ref_genome="${ref}/r649.rename.fasta" ##REMENBER it is renamed
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
aligned_bam="/dfs7/jje/jenyuw/Eval-sv-temp/results/alignment"
SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/SVs"
assemble="/dfs7/jje/jenyuw/Eval-sv-temp/results/assemble"
scaffold="/dfs7/jje/jenyuw/Eval-sv-temp/results/scaffold"
nT=$SLURM_CPUS_PER_TASK
source ~/.bashrc

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_2.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `

## try "assembly" as query and minimap2 "asm5" preset. 
#The F1 score of nanopore2018_100_1 is 0.9604690117252932 with much fewer false positive
file=${assemble}/${name}_flye/assembly.fasta

minimap2 -t ${nT} -a -x asm5 --cs -r2k \
${ref_genome} ${file} |\
samtools view -b -h -@ ${nT} -o -|samtools sort -@ ${nT} -o ${aligned_bam}/${name}.flye-ref.sort.bam
samtools index ${aligned_bam}/${name}.flye-ref.sort.bam

conda activate sv-calling
svim-asm haploid --sample ${name}_svimASM --min_sv_size 50 \
${SVs}/${name}_svimASM ${aligned_bam}/${name}.flye-ref.sort.bam ${ref_genome}

cp ${SVs}/${name}_svimASM/variants.vcf ${SVs}/${name}.svimASM.vcf
conda deactivate


: <<'SKIP'
##try "assembly" as query --> F1 score of nanopore2018_100_1 is 0.9500831946755408 with less false positive.
file=${assemble}/${name}_flye/assembly.fasta

minimap2 -t ${nT} -a -x asm10 --cs -r2k \
${ref_genome} ${file} |\
samtools view -b -h -@ ${nT} -o -|samtools sort -@ ${nT} -o ${aligned_bam}/${name}.flye-ref.sort.bam
samtools index ${aligned_bam}/${name}.flye-ref.sort.bam

conda activate sv-calling
svim-asm haploid --sample ${name}_svimASM --min_sv_size 50 \
${SVs}/${name}_svimASM-asm ${aligned_bam}/${name}.flye-ref.sort.bam ${ref_genome}
cp ${SVs}/${name}_svimASM-asm/variants.vcf ${SVs}/${name}.svimASM-asm.vcf
conda deactivate

##try "scaffold" as query --> F1 score of nanopore2018_100_1 is 0.9486455044041883
file=${scaffold}/${name}/ragtag.scaffold.fasta

minimap2 -t ${nT} -a -x asm10 --cs -r2k \
${ref_genome} ${file} |\
samtools view -b -h -@ ${nT} -o -|samtools sort -@ ${nT} -o ${aligned_bam}/${name}.scfd-ref.sort.bam
samtools index ${aligned_bam}/${name}.scfd-ref.sort.bam

conda activate sv-calling
svim-asm haploid --sample ${name}_svimASM --min_sv_size 50 \
${SVs}/${name}_svimASM-scfd ${aligned_bam}/${name}.scfd-ref.sort.bam ${ref_genome}
cp ${SVs}/${name}_svimASM-scfd/variants.vcf ${SVs}/${name}.svimASM-scfd.vcf
conda deactivate
SKIP

echo "This is the end"