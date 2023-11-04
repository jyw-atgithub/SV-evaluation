#! /bin/bash

#SBATCH --job-name=qc
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=36
#SBATCH --mem-per-cpu=10G
source ~/.bashrc
#/pub/jenyuw/Software/LongQC-1.2.0c
#/data/homezvol2/jenyuw/.conda/envs/longqc/bin
#/pub/jenyuw/Software/LongQC
lqc="/pub/jenyuw/Software/LongQC-1.2.0c"
raw=/pub/jenyuw/Eval-sv-temp/raw
trimmed=/pub/jenyuw/Eval-sv-temp/results/trimmed
qc_report="/pub/jenyuw/Eval-sv-temp/results/qc_report"
jellyfish="/pub/jenyuw/Eval-sv-temp/results/jellyfish"



line=`head -n $SLURM_ARRAY_TASK_ID ${raw}/sample-info.csv |tail -n 1`
file_name=`echo ${line} |gawk -F "," '{print $1}'`
x_option=`echo ${line} |gawk -F "," '{print $2}'`
strain=`echo ${file_name} |gawk -F "." '{print $1}'`
echo "line is $line"
echo "file_name is $file_name"
echo "x_option is $x_option"
echo "strain is $strain"

#conda activate longqc
##--trim_output should be specified as a file, not a path to te folder
module load python/3.8.0

python ${lqc}/longQC.py sampleqc -x ${x_option} -p $SLURM_CPUS_PER_TASK \
-s ${strain} -o ${qc_report}/${strain}_longQC ${raw}/${file_name}
#--trim_output ${trimmed}/${strain}.qctrimmed.fasta 
#conda deactivate

conda activate qc
jellyfish count -C -m 25 -s 200G -t $SLURM_CPUS_PER_TASK -o ${jellyfish}/${strain}.jf <(zcat ${raw}/${file_name})
jellyfish histo -t $SLURM_CPUS_PER_TASK ${jellyfish}/${strain}.jf > ${jellyfish}/${strain}.histo
conda deactivate