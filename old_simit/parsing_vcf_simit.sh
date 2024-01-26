#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  Hifi_60x_0.999_1_cute

cat  Hifi_60x_0.999.vcf|grep -v "#"|sed -E 's/^11/2L/g;s/^12/2R/g;s/^13/3L/g;s/^14/3R/g'|\
gawk 'BEGIN {print "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tHifi_60x_0.999_1_cute"} \
 {print $1 "\t" $2 "\t" "id" $4 $2 "\t" "a" "\t" "\<" $4 "\>" "\t" "30" "\t" "PASS" "\t" "SVTYPE=" $4 ";" "SVLEN=" $3 ";" "END=" $2 "\t" "GT" "\t" $5a}' \
> body.txt

echo -e "##fileformat=VCFv4.0
##FILTER=<ID=PASS,Description="All filters passed">
##fileDate=99991122
##contig=<ID=2L,length=23513712>
##contig=<ID=2R,length=25286936>
##contig=<ID=3L,length=28110227>
##contig=<ID=3R,length=32079331>
##contig=<ID=4,length=1348131>
##contig=<ID=X,length=23542271>
##contig=<ID=Y,length=3667352>
##ALT=<ID=INS,Description="Insertion of novel sequence relative to the reference">
##ALT=<ID=DEL,Description="Deletion relative to the reference">
##ALT=<ID=DUP,Description="Region of elevated copy number relative to the reference">
##ALT=<ID=INV,Description="Inversion of reference sequence">
##ALT=<ID=BND,Description="Breakend of translocation">
##INFO=<ID=SVTYPE,Number=1,Type=String,Description="Type of structural variant">
##INFO=<ID=SVLEN,Number=1,Type=Integer,Description="Difference in length between REF and ALT alleles">
##INFO=<ID=END,Number=1,Type=Integer,Description=End position>
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">" > fakeheader.txt

cat fakeheader.txt body.txt |bgzip -@ 2 -c|bcftools sort -O z -o Hifi_60x_0.999_1.sort.vcf.gz

#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  Hifi_60x_0.999_1_cute

cat  ONT_60x_0.9.vcf|grep -v "#"|sed -E 's/^11/2L/g;s/^12/2R/g;s/^13/3L/g;s/^14/3R/g'|\
gawk 'BEGIN {print "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tHifi_60x_0.999_1_cute"} \
 {print $1 "\t" $2 "\t" "id" $4 $2 "\t" "a" "\t" "\<" $4 "\>" "\t" "30" "\t" "PASS" "\t" "SVTYPE=" $4 ";" "SVLEN=" $3 ";" "END=" $2 "\t" "GT" "\t" $5a}' \
> body.txt


cat fakeheader.txt body.txt |bgzip -@ 2 -c|bcftools sort -O z -o ONT_60x_0.9_1.sort.vcf.gz

cat  RSII_60x_0.937.vcf|grep -v "#"|sed -E 's/^11/2L/g;s/^12/2R/g;s/^13/3L/g;s/^14/3R/g'|\
gawk 'BEGIN {print "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tHifi_60x_0.999_1_cute"} \
 {print $1 "\t" $2 "\t" "id" $4 $2 "\t" "a" "\t" "\<" $4 "\>" "\t" "30" "\t" "PASS" "\t" "SVTYPE=" $4 ";" "SVLEN=" $3 ";" "END=" $2 "\t" "GT" "\t" $5a}' \
> body.txt


cat fakeheader.txt body.txt |bgzip -@ 2 -c|bcftools sort -O z -o RSII_60x_0.937_1.sort.vcf.gz