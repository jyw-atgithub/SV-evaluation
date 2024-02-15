#! /bin/bash

#SBATCH --job-name='mum&co'
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1-40
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

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_2.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `

cd ${SVs}

## try "assembly" as query --> F1 score of nanopore2018_100_1 is 0.9225283630470016, esp. better precision
file=${assemble}/${name}_flye/assembly.fasta
bash /pub/jenyuw/Software/MUMandCo-MUMandCov3.8/mumandco_v3.8.sh  \
-r ${ref_genome} -q ${file} \
-g 135000000 -o ${name}_mumco -t ${nT} -ml 50

: <<'SKIP'
## try "scaffold" as query --> F1 score of nanopore2018_100_1 is 0.9152215799614644
file=${scaffold}/${name}/ragtag.scaffold.fasta
bash /pub/jenyuw/Software/MUMandCo-MUMandCov3.8/mumandco_v3.8.sh  \
-r ${ref_genome} -q ${file} \
-g 135000000 -o ${name}_mumco-scfd -t ${nT} -ml 50
# -b option increase runtime a lot!
SKIP

cd ${SVs}/${name}_mumco_output

cat ${SVs}/${name}_mumco_output/${name}_mumco.SVs_all.vcf|grep "#" |\
#tr '\n' '\f' |\
##'\f' is a special character that dpes not exist in the file, so it is used as a temporary separator
#sed -e 's/\f##contig/>\f##contig/g;s/\f##query=/>\f##query=/;s/.fasta>/.fasta/' |\
#sed -e 's/\f##query_contig/>\f##query_contig/g;s/\f##INFO=<ID=END/>\f##INFO=<ID=END/;s/.fasta>/.fasta/' |\
#tr '\f' '\n' |\
grep -v "##query_contig" |sed 's/ type=.*.;,/,/g' |tr -d " "|\
sed 's/qCHR/Q_CHROM/g; s/qSTART/Q_START/g; s/qEND/Q_END/g' |\
#grep -v -E "##INFO|##ALT|##FORMAT"|
sed 's/##INFO=<ID=END,Number=1,Type=Integer,Description=Endpositioninthereferencegenome>/##INFO=<ID=END,Number=1,Type=Integer,Description="End position of the variant described in this record">/g' |\
sed 's/##INFO=<ID=SVLEN,Number=.,Type=Integer,Description=DifferenceinlengthbetweenREFandALTalleles>/##INFO=<ID=SVLEN,Number=1,Type=Integer,Description="Difference in length between REF and ALT alleles">/g' |\
sed 's/##INFO=<ID=SVTYPE,Number=1,Type=String,Description=Typeofstructuralvariant>/##INFO=<ID=SVTYPE,Number=1,Type=String,Description="Type of structural variant">/g' |\
sed 's/##INFO=<ID=Q_CHROM,Number=1,Type=String,Description=Chromosomeinquerygenome>/##INFO=<ID=Q_CHROM,Number=1,Type=String,Description=Chromosome in query genome>/g' |\
sed 's/##INFO=<ID=Q_START,Number=1,Type=Integer,Description=Startpositioninquerygenome>/##INFO=<ID=Q_START,Number=1,Type=Integer,Description="Start position in query genome">/g' |\
sed 's/##INFO=<ID=Q_END,Number=1,Type=Integer,Description=Endpositioninquerygenome>/##INFO=<ID=Q_END,Number=1,Type=Integer,Description="End position in query genome">/g' |\
sed -e "s/##ALT=<ID=CONTR,Description=Contraction>\n//g" |\
sed 's/##ALT=<ID=DUP:TANDEM,Description=TandemDuplication>/##ALT=<ID=DUP,Description="Duplication">/g' |\
sed 's/##ALT=<ID=DEL,Description=Deletion>/##ALT=<ID=DEL,Description="Deletion">/g' |\
sed 's/##ALT=<ID=INS,Description=Insertionofnovelsequence>/##ALT=<ID=INS,Description="Insertion of novel sequence">/g' |\
sed 's/##ALT=<ID=INV,Description=Inversion>/##ALT=<ID=INV,Description="Inversion">/g' |\
sed 's/##ALT=<ID=TRA,Description=Regioninvolvedintranslocationalternativetoabreakendposition>/##ALT=<ID=TRA,Description="Breakend">/g' \
>${SVs}/${name}_mumco_output/header.pre


## making VCF
grep -v "#" ${SVs}/${name}_mumco_output/${name}_mumco.SVs_all.vcf |\
sed 's/CONTR/DEL/g; s/qCHR/Q_CHROM/g; s/qSTART/Q_START/g; s/qEND/Q_END/g'|\
gawk '{print $1 "\t" $2 "\t" $1"_"$2 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9 "\t" $10 }' >${SVs}/${name}_mumco_output/container.pre
#contractions are treated as deletions!

cat ${SVs}/${name}_mumco_output/header.pre ${SVs}/${name}_mumco_output/container.pre >${SVs}/${name}_mumco_output/${name}_mumco.good.vcf
bgzip -@ ${nT} -f -k ${SVs}/${name}_mumco_output/${name}_mumco.good.vcf
bcftools sort -O z ${SVs}/${name}_mumco_output/${name}_mumco.good.vcf.gz >${SVs}/${name}.mumco.good.sort.vcf.gz
bcftools index -t -f ${SVs}/${name}.mumco.good.sort.vcf.gz

echo "This is the end!!"
