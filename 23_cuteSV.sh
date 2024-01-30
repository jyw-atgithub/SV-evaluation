#!/bin/bash

#SBATCH --job-name=cuteSV
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1%1
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=6G

source ~/.bashrc

ref="/dfs7/jje/jenyuw/Eval-sv-temp/reference"
ref_genome="${ref}/r649.rename.fasta" ##REMENBER it is renamed
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
aligned_bam="/dfs7/jje/jenyuw/Eval-sv-temp/results/alignment"
SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/SVs"

nT=$SLURM_CPUS_PER_TASK

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `
file="${aligned_bam}/${name}.trimmed-ref.sort.bam"

declare -A setting=(['pacbio2016']='CLR' ['nanopore2018']='ONT' ['nanopore2020']='ONT' ['nanopore2023']='ONT')
echo "The setting is ${setting[$read_type]}"


module load python/3.10.2
cd ${SVs} # for unknown reason, cuteSV does not save the file at our desired working directory

if [[ ${setting[$read_type]} == "CLR" ]]
then
    cuteSV --threads ${nT} --genotype --sample ${name}_cute \
    --min_support 10 \
    --min_size 50 --min_mapq 20 --min_read_len 500 \
    -L '-1' \
    --merge_del_threshold 270 --merge_ins_threshold 270 \
    --max_cluster_bias_INS 100 --diff_ratio_merging_INS 0.3 --max_cluster_bias_DEL 200 --diff_ratio_merging_DEL 0.5 \
    "${file}" "${ref_genome}" "${name}.cutesv.vcf" "${SVs}"
elif [[ ${setting[$read_type]} == "ONT" ]]
then
    cuteSV --threads ${nT} --genotype --sample ${name}_cute \
    --min_support 10 \
    --min_size 50 --min_mapq 20 --min_read_len 500 \
    -L '-1' \
    --merge_del_threshold 270 --merge_ins_threshold 270 \
    --max_cluster_bias_INS 100 --diff_ratio_merging_INS 0.3 --max_cluster_bias_DEL 100 --diff_ratio_merging_DEL 0.3 \
    "${file}" "${ref_genome}" "${name}.cutesv.vcf" "${SVs}"
elif [[ ${setting[$read_type]} == "hifi" ]]
then
    cuteSV --threads ${nT} --genotype --sample ${name}_cute \
    --min_support 10 \
    --min_size 50 --min_mapq 20 --min_read_len 500 \
    -L '-1' \
    --merge_del_threshold 270 --merge_ins_threshold 270 \
	--max_cluster_bias_INS 1000 --diff_ratio_merging_INS 0.9 --max_cluster_bias_DEL 1000 --diff_ratio_merging_DEL 0.5 \
    "${file}" "${ref_genome}" "${name}.cutesv.vcf" "${SVs}"
else
echo "The setting, ${setting[$read_type]}, is not recognized"
fi

module unload python/3.10.2

echo "The cuteSV is done for ${name}"