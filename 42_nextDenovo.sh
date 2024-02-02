#! /bin/bash

#SBATCH --job-name=ND
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=10G
#SBATCH --output=nd-%A_%a.out


trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
assemble="/dfs7/jje/jenyuw/Eval-sv-temp/results/assemble"
nT=$SLURM_CPUS_PER_TASK
source ~/.bashrc

file=`head -n $SLURM_ARRAY_TASK_ID ${trimmed}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 8 |cut -d '.' -f 1 `
read_type=`echo ${name} | cut -d '_' -f 1 `
declare -A preset_option=(['pacbio2016']='clr' ['nanopore2018']='ont' ['nanopore2020']='ont' ['nanopore2023']='ont')

echo ${file} > ${assemble}/${SLURM_ARRAY_TASK_ID}.input.fofn

echo -e "
job_type = local
job_prefix = nextDenovo
task = all
rewrite = yes
deltmp = yes

parallel_jobs =8 #M gb memory, between M/64~M/32
input_type = raw
read_type = ${preset_option[$read_type]} # clr, ont, hifi
input_fofn = ${assemble}/${SLURM_ARRAY_TASK_ID}.input.fofn
workdir = ${assemble}/${name}_nextdenovo

[correct_option]
read_cutoff = 1k
genome_size = 135m
seed_depth = 32 #you can try to set it 30-45 to get a better assembly result
seed_cutoff = 0
sort_options = -m 40g -t 4 #m=M/(TOTAL_INPUT_BASES * 1.2/4)
minimap2_options_raw = -t 4
pa_correction = 3 #M/(TOTAL_INPUT_BASES * 1.2/4)
correction_options = -p 4  #P cores, P/parallel_jobs

[assemble_option]
minimap2_options_cns = -t 4 -k17 -w17
minimap2_options_map = -t 4 #P cores, P/parallel_jobs
nextgraph_options = -a 1 -q 10 #usually best according to the authors
" >${assemble}/${SLURM_ARRAY_TASK_ID}.run.cfg

nextDenovo ${assemble}/${SLURM_ARRAY_TASK_ID}.run.cfg

rm ${assemble}/${SLURM_ARRAY_TASK_ID}.input.fofn ${assemble}/${SLURM_ARRAY_TASK_ID}.run.cfg
echo "It is the end"