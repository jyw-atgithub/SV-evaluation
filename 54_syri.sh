#! /bin/bash

#########NOT WORKING WELL###############


#SBATCH --job-name=syri
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=6G
#SBATCH --constraint=fastscratch  ###MUST use fast scratch for mum&co!!

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
ref_genome="${ref}/r649.rename.fasta" ##REMENBER it is renamed
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
aligned_bam="/dfs7/jje/jenyuw/Eval-sv-temp/results/alignment"
SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/SVs"
assemble="/dfs7/jje/jenyuw/Eval-sv-temp/results/assemble"
scaffold="/dfs7/jje/jenyuw/Eval-sv-temp/results/scaffold"

nT=$SLURM_CPUS_PER_TASK
source ~/.bashrc

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `

#use the assembly as input
file=${assemble}/${name}_flye/assembly.fasta

mkdir ${SVs}/${name}_SYRI
cd ${SVs}/${name}_SYRI

: <<'SKIP'
minimap2 -t ${nT} -a -x asm5 --eqx \
${ref_genome} ${file} |\
samtools view -h -@ ${nT} -O SAM |samtools sort -O SAM -@ ${nT} |\
samtools view -@ ${nT} -h --bam -o ${SVs}/${name}_SYRI/${name}.final-ref.sort.bam

cp ${file} ${SVs}/${name}_SYRI/${name}.scaffold.fasta
SKIP

module load python/3.10.2
ragtag.py scaffold -r -w --aligner 'minimap2' -t ${nT} \
-o ${SVs}/${name}_SYRI/ragtag_out ${ref_genome} ${file}

cat ${SVs}/${name}_SYRI/ragtag_out/ragtag.scaffold.fasta|sed 's/_RagTag//g' > ${SVs}/${name}_SYRI/${name}.scaffold.fasta

minimap2 -t ${nT} -a -x asm5 --eqx \
${ref_genome} ${SVs}/${name}_SYRI/${name}.scaffold.fasta |\
samtools view -h -@ ${nT} -O SAM |samtools sort -O SAM -@ ${nT} |\
samtools view -@ ${nT} -h --bam -o ${SVs}/${name}_SYRI/${name}.final-ref.sort.bam

cp ${ref_genome} ${SVs}/${name}_SYRI/r649.ref.fasta

fixchr -c ${SVs}/${name}_SYRI/${name}.final-ref.sort.bam -F B \
-r ${SVs}/${name}_SYRI/r649.ref.fasta -q ${SVs}/${name}_SYRI/${name}.scaffold.fasta \
-f --contig_size 100000 --dir ${SVs}/${name}_SYRI --prefix ${name}

cat ${SVs}/${name}_SYRI/ref.filtered.fa| sed s/'>4'/'>chr4'/g > ${SVs}/${name}_SYRI/ref.filtered.rn.fa
cat ${SVs}/${name}_SYRI/qry.filtered.fa| sed s/'>4'/'>chr4'/g > ${SVs}/${name}_SYRI/qry.filtered.rn.fa

minimap2 -t ${nT} -a -x asm5 --cs --eqx \
${SVs}/${name}_SYRI/ref.filtered.rn.fa  ${SVs}/${name}_SYRI/qry.filtered.rn.fa |\
samtools view -b -h -@ ${nT} -o -|samtools sort -@ ${nT} -o ${SVs}/${name}_SYRI/sort.bam
samtools index ${SVs}/${name}_SYRI/sort.bam

syri -F B -c ${SVs}/${name}_SYRI/sort.bam -r ${SVs}/${name}_SYRI/ref.filtered.rn.fa \
-q ${SVs}/${name}_SYRI/qry.filtered.rn.fa --dir ${SVs}/${name}_SYRI \
--nc 3 --samplename ${name}_SYRI --prefix ${name}_mm2 --unic 500

module unload python/3.10.2

rm ${SVs}/${name}_SYRI/${name}.final-ref.sort.bam
rm ${SVs}/${name}_SYRI/r649.ref.fasta
rm ${SVs}/${name}_SYRI/${name}.scaffold.fasta
rm ${SVs}/${name}_SYRI/ref.filtered.fa
rm ${SVs}/${name}_SYRI/qry.filtered.fa
##grep -v "^#" result/SVs/A1_CLR_SYRI/syri.vcf | gawk '{print $3}' | cut -c 1-3 |sort |uniq -c

echo "This is the end!!"