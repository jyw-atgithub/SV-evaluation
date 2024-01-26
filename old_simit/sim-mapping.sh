#! /bin/bash

#SBATCH --job-name=mapping
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=28
#SBATCH --mem-per-cpu=6G
source ~/.bashrc

sim_raw="/dfs7/jje/jenyuw/Eval-sv-temp/sim_raw"
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
ref_genome="/dfs7/jje/jenyuw/Eval-sv-temp/reference/dmel-all-chromosome-r6.49.fasta"
aligned_bam="/dfs7/jje/jenyuw/Eval-sv-temp/results/aligned_bam"

nT=$SLURM_CPUS_PER_TASK

#ls ${sim_raw}/*_60x_*_1/Long_reads_*_HAP1.fasta >${sim_raw}/namelist_1.txt
#Hifi_60x_0.999_1/Long_reads_Hifi_60x_0.999_HAP1.fasta
#ONT_60x_0.9_1/Long_reads_ONT_60x_0.9_HAP1.fasta

file=`head -n $SLURM_ARRAY_TASK_ID ${sim_raw}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 7 `
read_type=`echo ${name} | cut -d '_' -f 1 `
##!!!Importent!! remeber to declare the array##
declare -A mapping_option=(['Hifi']='map-hifi' ['RSII']='map-pb' ['Sequel2']='map-pb' ['ONT']='map-ont' ['ONThq']='map-ont')
echo "The mapping option is ${mapping_option[$read_type]}"

minimap2 -t ${nT} -a -x ${mapping_option[$read_type]} ${ref_genome} ${file} |\
samtools view -b -h -@ ${nT} -o - |\
samtools sort -@ ${nT} -o ${aligned_bam}/${name}.trimmed-ref.sort.bam
samtools index -@ ${nT} ${aligned_bam}/${name}.trimmed-ref.sort.bam
