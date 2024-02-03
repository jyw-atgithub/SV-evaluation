#! /bin/bash

#SBATCH --job-name=svmu
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=20
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

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `

#the input is the scaffold
file=${scaffold}/${name}/ragtag.scaffold.fasta

mkdir ${SVs}/${name}_svmu
nucmer --threads ${nT} --delta=${SVs}/${name}_svmu/${name}.delta ${ref_genome} ${file}
#conda activate sv-calling
#lastz ${ref_genome}[multiple] ${file}[multiple] --chain --format=general:name1,strand1,start1,end1,name2,strand2,start2,end2 > ${SVs}/${name}_svmu/${name}.lastz.txt
#conda deactivate

cd ${SVs}/${name}_svmu
svmu ${SVs}/${name}_svmu/${name}.delta ${ref_genome} ${file} l ${SVs}/${name}_svmu/${name}.lastz.txt ${name}

query_genome=${file}
sample_name="${name}_svmu"
input="${SVs}/${name}_svmu/sv.${name}.txt"

################# transform svmu table to VCF4.2#################
##part1, create the header
echo -e "##fileformat=VCFv4.2
##fileDate=$(date '+%Y%m%d %H:%M:%S')
##source=svmu
##contig=<ID=2L,length=23513712>
##contig=<ID=2R,length=25286936>
##contig=<ID=3L,length=28110227>
##contig=<ID=3R,length=32079331>
##contig=<ID=4,length=1348131>
##contig=<ID=X,length=23542271>
##contig=<ID=Y,length=3667352>
##ALT=<ID=DEL,Description="Deletion">
##ALT=<ID=INV,Description="Inversion">
##ALT=<ID=DUP,Description="Duplication">
##ALT=<ID=INS,Description="Insertion">
##INFO=<ID=SVTYPE,Number=1,Type=String,Description="Type of structural variant">
##INFO=<ID=END,Number=1,Type=Integer,Description="End position of the variant described in this record">
##INFO=<ID=SVLEN,Number=1,Type=Integer,Description="Difference in length between REF and ALT alleles">
##INFO=<ID=Q_CHROM,Number=1,Type=String,Description="Chromosome of the query sequence">
##INFO=<ID=Q_START,Number=1,Type=Integer,Description="Start position of the query sequence">
##INFO=<ID=Q_END,Number=1,Type=Integer,Description="End position of the query sequence">
##FILTER=<ID=PASS,Description="All filters passed">
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t${sample_name}" >${SVs}/${name}_svmu/${sample_name}.header.txt

##part2, create the body
#1. REF_CHROM       2. REF_START       3. REF_END 4. SV_TYPE 5. Q_CHROM 6. Q_START 7. Q_END   8. ID      9. LEN     10. COV_REF COV_Q
#1-CHROM  2-POS     3-ID      4-REF     5-ALT     6-QUAL    7-FILTER  8-INFO    9-FORMAT  10-Hifi_60x_0.999_1_cute
#named pipes worked so slowly.
#Only preserve the major chromosomes in both reference and query
cat ${input}| gawk ' ( ($1 == "2L") || ($1 == "2R") || ($1 == "3L") || ($1 == "3R") || ($1 == "4") || ($1 == "X") || ($1 == "Y")) {print $0}' |\
grep -E 'X_RagTag|2L_RagTag|2R_RagTag|3L_RagTag|3R_RagTag|4_RagTag' > ${SVs}/${name}_svmu/filtered_temp.txt

printf "" >${sample_name}.body.txt
#($4 != "nCNV-R")&& ($4 != "CNV-R") Do not involve the nCNV-R and CNV-R (in the reference)
#&& (NR > 1) skip the header
#&& ($9 > 50) SVLEN longer than 50bp

##backup:cat filtered_temp.txt| gawk ' ($4 != "nCNV-R") && ($4 != "CNV-R") && (NR > 1) && ($9 > 50) && ($9 < 30000000) {print $0}'

#INS as INS
cat filtered_temp.txt| gawk ' ($4 != "nCNV-R") && ($4 != "CNV-R") && (NR > 1) && ($9 < 30000000) {print $0}'|\
gawk ' $4=="INS" {print $1 "\t"  $2 "\t" "INS_" $8 "\t" "REF_seq" "\t" "ALT_seq" "\t" "30" "\t" "PASS" "\t" "SVTYPE=INS;SVLEN=" $9 ";END=" $3 ";Q_CHROM=" $5 ";Q_START=" $6 ";Q_END=" $7 "\t" "GT" "\t" "1/1"}' >>${SVs}/${name}_svmu/${sample_name}.body.txt
#DEL as DEL
cat filtered_temp.txt| gawk ' ($4 != "nCNV-R") && ($4 != "CNV-R") && (NR > 1) && ($9 < 30000000) {print $0}'|\
gawk ' $4=="DEL" {print $1 "\t"  $2 "\t" "DEL_" $8 "\t" "REF_seq" "\t" "ALT_seq" "\t" "30" "\t" "PASS" "\t" "SVTYPE=DEL;SVLEN=" 0 - $9 ";END=" $3 ";Q_CHROM=" $5 ";Q_START=" $6 ";Q_END=" $7 "\t" "GT" "\t" "1/1"}' >>${SVs}/${name}_svmu/${sample_name}.body.txt
#CNV-Q as DUP #nCNV-Q aslo as DUP
cat filtered_temp.txt| gawk ' ($4 != "nCNV-R") && ($4 != "CNV-R") && (NR > 1) && ($9 < 30000000) {print $0}'|\
gawk ' ( ($4=="CNV-Q") || ($4=="nCNV-Q") ) && ($9 > 0) && ( $7 > $6 ) {print $1 "\t"  $2 "\t" "DUP_" $8 "\t" "REF_seq" "\t" "ALT_seq" "\t" "30" "\t" "PASS" "\t" "SVTYPE=DUP;SVLEN=" $9 ";END=" $3 ";Q_CHROM=" $5 ";Q_START=" $6 ";Q_END=" $7 "\t" "GT" "\t" "1/1"} ' >>${SVs}/${name}_svmu/${sample_name}.body.txt
##some CNV contains end < start, so we need to switch the start and end ";Q_START=" $7 ";Q_END=" $6
cat filtered_temp.txt| gawk ' ($4 != "nCNV-R") && ($4 != "CNV-R") && (NR > 1) && ($9 < 30000000) {print $0}'|\
gawk ' ( ($4=="CNV-Q") || ($4=="nCNV-Q") ) && ($9 > 0) && ( $6 > $7 ) {print $1 "\t"  $2 "\t" "DUP_" $8 "\t" "REF_seq" "\t" "ALT_seq" "\t" "30" "\t" "PASS" "\t" "SVTYPE=DUP;SVLEN=" $9 ";END=" $3 ";Q_CHROM=" $5 ";Q_START=" $7 ";Q_END=" $6 "\t" "GT" "\t" "1/1"}' >>${SVs}/${name}_svmu/${sample_name}.body.txt
##The length of INV were noted ad both Positive and NEgative !!
## only keep the INV with positive length
#INV as INV
## The Reference END of inversions are Wrong!! It should be the start + length!! $3 + $9
cat filtered_temp.txt| gawk ' ($4 != "nCNV-R") && ($4 != "CNV-R") && (NR > 1) && ($9 < 30000000) {print $0}'|\
gawk ' ($4=="INV") && ($9 > 0) && ($7 >$6) {print $1 "\t"  $2 "\t" "INV_" $8 "\t" "REF_seq" "\t" "ALT_seq" "\t" "30" "\t" "PASS" "\t" "SVTYPE=INV;SVLEN=" $9 ";END=" $3 + $9 ";Q_CHROM=" $5 ";Q_START=" $6 ";Q_END=" $7 "\t" "GT" "\t" "1/1"}' >>${SVs}/${name}_svmu/${sample_name}.body.txt
##Some inversions have end < start, so we need to switch!! ";Q_START=" $7 ";Q_END=" $6
cat filtered_temp.txt| gawk ' ($4 != "nCNV-R") && ($4 != "CNV-R") && (NR > 1) && ($9 < 30000000) {print $0}'|\
gawk ' ($4=="INV") && ($9 > 0) && ($6 >$7) {print $1 "\t"  $2 "\t" "INV_" $8 "\t" "REF_seq" "\t" "ALT_seq" "\t" "30" "\t" "PASS" "\t" "SVTYPE=INV;SVLEN=" $9 ";END=" $3 + $9 ";Q_CHROM=" $5 ";Q_START=" $7 ";Q_END=" $6 "\t" "GT" "\t" "1/1"}' >>${SVs}/${name}_svmu/${sample_name}.body.txt



printf "" >  ${SVs}/${name}_svmu/${sample_name}.good.body.txt
counter=0
#make the negative SVLEN into positive
cat ${SVs}/${name}_svmu/${sample_name}.body.txt|sed s/"SVLEN=-"/"SVLEN="/g|while read line
do
    svtype=`echo $line|gawk '{print $3}'|gawk -F "_" '{print $1}'`
    ref_chrom=`echo $line|gawk '{print $1}'`
    ref_start=`echo $line|gawk '{print $2}'`
    ref_end=`echo $line|gawk '{print $8}'|gawk -F ";" '{print $3}'|gawk -F "=" '{print $2}'`
    q_chrom=`echo $line|gawk '{print $8}'|gawk -F ";" '{print $4}'|gawk -F "=" '{print $2}'`
    q_start=`echo $line|gawk '{print $8}'|gawk -F ";" '{print $5}'|gawk -F "=" '{print $2}'`
    q_end=`echo $line|gawk '{print $8}'|gawk -F ";" '{print $6}'|gawk -F "=" '{print $2}'`
    counter=$((counter+1))
    echo "Current SVTYPE is ${svtype}"
    echo "Current line is ${counter}"
## We have to split the sequence because some of them are too long. 
##"bash: /usr/bin/sed: Argument list too long"
    echo -e "${ref_chrom}\t${ref_start}\t$((ref_end + 1))">${SVs}/${name}_svmu/temp.1.bed
    real_r_seq=`bedtools getfasta -fi ${ref_genome} -bed ${SVs}/${name}_svmu/temp.1.bed 2>>err.1.txt|gawk '{if (NR==2) print $1}'`
    #if [[ ${#real_r_seq} > 0 ]]
    #then
        for ((len=${#real_r_seq};len>0;len=len-100000))
        do
        insert=`echo -n ${real_r_seq}|cut -c 1-100000`
        line=`echo -n ${line}|sed s@"REF_seq"@${insert}REF_seq@`
        real_r_seq=`echo -n ${real_r_seq}|cut -c 100001-`
        #echo "Current length is ${len}"
        done
        line=`echo ${line}|sed s@"REF_seq"@@`
    #fi
    echo -e "${q_chrom}\t${q_start}\t$((q_end + 1))">${SVs}/${name}_svmu/temp.2.bed
    real_q_seq=`bedtools getfasta -fi ${query_genome} -bed ${SVs}/${name}_svmu/temp.2.bed 2>>err.2.txt |gawk '{if (NR==2) print $1}'`
    #if [[ ${#real_q_seq} > 0 ]]
        #then
        for ((len=${#real_q_seq};len>0;len=len-100000))
        do
        insert=`echo -n ${real_q_seq}|cut -c 1-100000`
        line=`echo -n ${line}|sed s@"ALT_seq"@${insert}ALT_seq@`
        real_q_seq=`echo -n ${real_q_seq}|cut -c 100001-`
        done
        line=`echo ${line}|sed s@"ALT_seq"@@`
    #fi
    #if [[ grep -E -q "REF_seq|ALT_seq" <(echo $line) ]]
    #then
        #echo "There are some REF_seq or ALT_seq left in the line"
    #fi
    echo ${line}|gawk ' NF == 10 {print $0}'| tr -s " " "\t" >>${SVs}/${name}_svmu/${sample_name}.good.body.txt
done


init=`wc -l ${input}|gawk '{print $1}'`
final=`wc -l ${SVs}/${name}_svmu/${sample_name}.good.body.txt|gawk '{print $1}'`
echo "There are" $init "lines in the input file"
echo "There are" $final "lines in the output file"
echo "Thus, there are" $((init-final)) "lines were filtered out"

cat ${input}| gawk ' ($9 > 0) && ($9 <= 50) {print $0}' > ${SVs}/${name}_svmu/${sample_name}.short.txt
cat ${input}| gawk ' ($4=="INV") && ($9 <= 0) {print $0}' > ${SVs}/${name}_svmu/${sample_name}.weird_INV.txt
cat ${input}| gawk ' ($4 == "CNV-Q") && ($9 <= 0) {print $0}' > ${SVs}/${name}_svmu/${sample_name}.weird_CNVQ.txt

cat ${SVs}/${name}_svmu/${sample_name}.header.txt ${SVs}/${name}_svmu/${sample_name}.good.body.txt >${SVs}/${name}_svmu/${sample_name}.vcf

bcftools view --with-header --threads ${nT} ${SVs}/${name}_svmu/${sample_name}.vcf |\
bcftools sort --max-mem 2G -O z -o ${SVs}/${name}_svmu/${sample_name}.vcf.gz
bcftools index -f -t ${SVs}/${name}_svmu/${sample_name}.vcf.gz

cp ${SVs}/${name}_svmu/${sample_name}.vcf.gz ${SVs}/${name}.svmu.vcf.gz
cp ${SVs}/${name}_svmu/${sample_name}.vcf.gz.tbi ${SVs}/${name}.svmu.vcf.gz.tbi