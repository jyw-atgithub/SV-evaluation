#! /bin/bash

#SBATCH --job-name=racon
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=32
#SBATCH --mem-per-cpu=10G
source ~/.bashrc

sim_raw="/dfs7/jje/jenyuw/Eval-sv-temp/sim_raw"
trimmed="/dfs7/jje/jenyuw/Eval-sv-temp/results/trimmed"
assemble="/dfs7/jje/jenyuw/Eval-sv-temp/results/assemble"
aligned_bam="/dfs7/jje/jenyuw/Eval-sv-temp/results/aligned_bam"
polishing="/dfs7/jje/jenyuw/Eval-sv-temp/results/polishing"
nT=$SLURM_CPUS_PER_TASK


function polish_Ra {
# THREE input argumants:"path" tech rounds
# ${i} will be one of the assemblers
for k in $(ls $1 2> /dev/null)
do
#echo "first arg is " $1
#echo "second arg is " $2
echo "k is " "$k"
name=$(echo $k | gawk -F "/" '{print $8}' | sed "s/_${i}//g")
echo $name
read=${trimmed}/${name}.trimmed.fasta.gz
##Be careful!!! ".trimmed.fastA.gz"
read_type=$2
declare -A mapping_option=(['Hifi']='map-hifi' ['RSII']='map-pb' ['Sequel2']='map-pb' ['ONT']='map-ont' ['ONThq']='map-ont')
echo "The mapping option is ${mapping_option[$read_type]}"

if [[ $2 != "Hifi" && $2 != "ONT" && $2 != "ONThq" && $2 != "RSII" && $2 != "Sequel2" ]]
then
echo "The second argument can only be one of \"CLR, hifi, ONT\""
fi
round=$3
input=${k}
for ((count=1; count<=${round};count++))
do
echo "round $count"
echo "input is $input"
echo "the mapping option is ${mapping_option[$read_type]}"
minimap2 -x ${mapping_option[$read_type]} -t ${nT} -o ${aligned_bam}/${name}.trimmed-${i}.paf ${input} ${read}
echo "after manimap2"
racon -t ${nT} ${read} ${aligned_bam}/${name}.trimmed-${i}.paf ${input} >${polishing}/${name}.${i}.racon.fasta
echo "after racon"
if ((${count}!=${round}))
then
mv ${polishing}/${name}.${i}.racon.fasta ${polishing}/${name}.${i}.racontmp.fasta
input=${polishing}/${name}.${i}.racontmp.fasta
echo "round round round"
fi
done
rm ${aligned_bam}/${name}.trimmed-${i}.paf
rm ${polishing}/${name}.${i}.racontmp.fasta
done
}


#ls ${sim_raw}/*_60x_*_1/Long_reads_*_HAP1.fasta >${sim_raw}/namelist_1.txt

file=`head -n $SLURM_ARRAY_TASK_ID ${sim_raw}/namelist_1.txt |tail -n 1`
name=`echo ${file} | cut -d '/' -f 7 `
read_type=`echo ${name} | cut -d '_' -f 1 `
echo "the file is ${file}"
echo "the read type is ${read_type}"


conda activate post-proc
assembler="flye nextdenovo-32"
for i in `echo $assembler`
do
    if [[ $i == "flye" ]]
    then
    echo "racon $i assembly now"
    polish_Ra "${assemble}/${name}_${i}/assembly.fasta" "${read_type}" "3"
    elif [[ $i == "canu" ]]
    then
    echo "racon $i assembly now"
    polish_Ra "${assemble}/${name}_${i}/*.contigs.fasta" "${read_type}" "3"
    elif [[ $i == "nextdenovo-32" ]]
    then
    echo "racon $i assembly now"
    polish_Ra "${assemble}/${name}_${i}/03.ctg_graph/nd.asm.fasta" "${read_type}" "3"
    else
    echo "NO such assembler was used"
    fi
done
conda deactivate
echo "It is the end!!"