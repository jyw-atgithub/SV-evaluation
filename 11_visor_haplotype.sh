#!/bin/bash
ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
sim="/dfs7/jje/jenyuw/Eval-sv-temp/simulation"
nT=16

cd $sim
module load R/4.2.2
module load python/3.8.0

cut -f1,2 ${ref}/r649.rename.fasta.fai > ${sim}/chrom.dim.tsv

#-r '30:30:10:10:10:10' is the sum of the RATIO, total is 100%, NOT the count
#-n number of SVs
#-l length of SVs
#-s standard deviation of SV length
Rscript ${sim}/randomregion.r -d chrom.dim.tsv -i 1 -n 3000 -l 6000 -s 1800 \
-v 'insertion,deletion,inversion,tandem duplication,translocation cut-paste,translocation copy-paste' \
-r '49:48:1:1.6:0.2:0.2' -g ${ref}/r649.rename.fasta |\
bedtools sort > ${sim}/HACk.random.bed

VISOR HACk -g ${ref}/r649.rename.fasta -b ${sim}/HACk.random.bed -o hap_1

cut -f1,2 ${sim}/hap_1/h1.fa.fai ${ref}/r649.rename.fasta.fai > ${sim}/haplochroms.dim.tsv

cat ${sim}/haplochroms.dim.tsv | sort|\
gawk '$2 > maxvals[$1] {lines[$1]=$0; maxvals[$1]=$2} END { for (tag in lines) print lines[tag] }' > ${sim}/maxdims.tsv

#coverage fluctuations (capture bias) value is the 4th column; purity value is the 5th column (100.0 means no contamination)
#in awk: int() returns integer; rand() returns random number between 0 and 1; int(rand()*11)+90 returns 9 to 100
awk 'OFS=FS="\t"''{print $1, "1", $2, "100.0", "100.0"}' ${sim}/maxdims.tsv > reads.simple.bed
