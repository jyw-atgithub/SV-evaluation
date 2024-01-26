#!/bin/bash
ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
sim="/dfs7/jje/jenyuw/Eval-sv-temp/simulation"
nT=16

cd $sim
module load R/4.2.2
module load python/3.8.0

cut -f1,2 ${ref}/r649.rename.fasta.fai > ${sim}/chrom.dim.tsv

Rscript ${sim}/randomregion.r -d chrom.dim.tsv -n 100 -l 4000 -s 1000 \
-v 'insertion,deletion,inversion,tandem duplication,translocation cut-paste,translocation copy-paste' \
-r '46:46:3:3:1:1' -i 1 -g ${ref}/r649.rename.fasta |\
bedtools sort > ${sim}/HACk.random.bed

VISOR HACk -g ${ref}/r649.rename.fasta -b ${sim}/HACk.random.bed -o test_hap_1

cut -f1,2 ${sim}/test_hap_1/h1.fa.fai ${ref}/r649.rename.fasta.fai > ${sim}/haplochroms.dim.tsv

cat ${sim}/haplochroms.dim.tsv | sort|\
gawk '$2 > maxvals[$1] {lines[$1]=$0; maxvals[$1]=$2} END { for (tag in lines) print lines[tag] }' > ${sim}/maxdims.tsv

#coverage fluctuations (capture bias) value is the 4th column; purity value is the 5th column (100.0 means no contamination)
#in awk: int() returns integer; rand() returns random number between 0 and 1; int(rand()*11)+90 returns 9 to 100
awk 'OFS=FS="\t"''{print $1, "1", $2, "100.0", "100.0"}' ${sim}/maxdims.tsv > reads.simple.bed

#read_type="nanopore" or "pacbio"
VISOR LASeR -g ${ref}/r649.rename.fasta -s ${sim}/test_hap_1 -b ${sim}/reads.simple.bed -o ONT_60_1 \
--tag --fastq  --compress \
--threads ${nT} \
--coverage 60  --read_type nanopore \
--length_mean 15000 --length_stdev 5000 \
--identity_min 90 --identity_max 96 --identity_stdev 4 \
--error_model "nanopore2023" --qscore_model "nanopore2023" --junk_reads 0.5