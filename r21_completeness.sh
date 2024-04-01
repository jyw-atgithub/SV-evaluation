#!/bin/bash

#SBATCH --job-name="compleatness"    ## Name of the job.
#SBATCH -A jje_lab       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --array=1      ## number of tasks to launch (wc -l prefixes.txt)
#SBATCH --cpus-per-task=16   ## number of cores the job needs
#SBATCH --mem-per-cpu=6G     # requesting 6 GB memory per CPU, the max

assemble="/dfs7/jje/jenyuw/Eval-sv-temp/results/assemble"
busco="/dfs7/jje/jenyuw/Eval-sv-temp/results/busco"
compleasm="/dfs7/jje/jenyuw/Eval-sv-temp/results/compleasm"
compleasm_kit="/pub/jenyuw/Software/compleasm_kit"
source ~/.bashrc
nT=$SLURM_CPUS_PER_TASK
#newgrp jje

module load anaconda/2022.05
conda activate BUSCO

echo -e "iso1_R941_flye
iso1_R1041_flye
iso1_hifi_flye
SRR22822929_R1041_flye
SRR22822930_R1041_flye
SRR11906526_RSII_flye
SRR11906525_Sequel_flye
iso1_hifi_hifiasm-4
iso1_hifi_hifiasm-3
iso1_hifi_hifiasm-2
iso1_hifi_hifiasm-1" >${assemble}/iso1.list.txt

item=`head -n $SLURM_ARRAY_TASK_ID ${assemble}/iso1.list.txt |tail -n 1`
read_type=`echo ${item} |  cut -d '_' -f 2`
assembler=`echo ${item} |  cut -d '_' -f 3`

#awk '/^S/{print ">"$2;print $3}' *.p_ctg.gfa > assembly.fasta

busco -f -i ${assemble}}/${item}/assembly.fasta \
--out_path ${busco} \
-o iso1_${read_type}_${assembler} \
-l diptera_odb10 -m genome -c ${nT}

conda deactivate
moduel unload anaconda/2022.05

module load python/3.10.2
#python3 ${compleasm_kit}/compleasm.py list --remote
#python3 ${compleasm_kit}/compleasm.py download diptera_odb10 -L ${compleasm_kit}/diptera_odb10

python ${compleasm_kit}/compleasm.py run -a ${assemble}}/${item}/assembly.fasta \
-o ${compleasm}/iso1_${read_type}_${assembler} \
-t ${nT} -l diptera_odb10 -L ${compleasm_kit}/diptera_odb10
moduel unload python/3.10.2