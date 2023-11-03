#! /bin/bash

#SBATCH --job-name=qc
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=30
#SBATCH --mem-per-cpu=8G
source ~/.bashrc

lqc=/pub/jenyuw/Software/LongQC-1.2.0c
raw=/pub/jenyuw/Eval-sv-temp/raw
trimmed=/pub/jenyuw/Eval-sv-temp/results/trimmed
qc_report="/pub/jenyuw/Eval-sv-temp/results/qc_report"
jellyfish="/pub/jenyuw/Eval-sv-temp/results/jellyfish"

conda activate longqc

line=`head -n $SLURM_ARRAY_TASK_ID ${raw}/sample-info.csv |tail -n 1`
file_name=`echo ${line} |gawk -F "," '{print $1}'`
x_option=`echo ${line} |gawk -F "," '{print $2}'`
strain=`echo ${file_name} |gawk -F "." '{print $1}'`
echo "line is $line"
echo "file_name is $file_name"
echo "x_option is $x_option"
echo "strain is $strain"

##--trim_output should be specified as a file, not a path to te folder
python  ${lqc}/longQC.py sampleqc -x ${x_option} -p $SLURM_CPUS_PER_TASK \
-s ${strain} --trim_output ${trimmed}/${strain}.qctrimmed.fasta -o ${qc_report}/${strain} ${raw}/${file_name}

conda deactivate

conda activate qc
jellyfish count -C -m 25 -s 200G -t $SLURM_CPUS_PER_TASK -o ${jellyfish}/${strain}.jf <(zcat ${raw}/${file_name})
jellyfish histo -t $SLURM_CPUS_PER_TASK ${jellyfish}/${strain}.jf > ${jellyfish}/${strain}.histo
conda deactivate