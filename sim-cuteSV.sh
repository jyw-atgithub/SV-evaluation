#! /bin/bash

#SBATCH --job-name=cute
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1-5%1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=6G

source ~/.bashrc

ref_genome="/dfs7/jje/jenyuw/Eval-sv-temp/reference/dmel-all-chromosome-r6.49.fasta"
aligned_bam="/dfs7/jje/jenyuw/Eval-sv-temp/results/aligned_bam"
SVs="/dfs7/jje/jenyuw/Eval-sv-temp/results/SVs"

nT=$SLURM_CPUS_PER_TASK

#ls ${aligned_bam}/*.trimmed-ref.sort.bam >${aligned_bam}/bamlist_1.txt

file=`head -n $SLURM_ARRAY_TASK_ID ${aligned_bam}/bamlist_1.txt |tail -n 1`
name=`basename ${file} | sed s/.trimmed-ref.sort.bam//g `
read_type=`echo ${name} | cut -d '_' -f 1 `

##!!!Importent!! remeber to declare the array##
declare -A setting=(['Hifi']='hifi' ['RSII']='CLR' ['Sequel2']='CLR' ['ONT']='ONT' ['ONThq']='ONT')
echo "The setting is ${setting[$read_type]}"


module load python/3.10.2
cd ${SVs} # for unknown reason, cuteSV does save the file at our desired directory

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