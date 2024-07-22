#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name="MetaKraken"
#-----------------------------Output files-----------------------------
#SBATCH --output=logs_slurm/output_%j.txt
#SBATCH --error=logs_slurm/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment='DK angsd'
#-----------------------------Required resources-----------------------
#SBATCH --time=5:00:00   # Adjust the time limit accordingly
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8  # Adjust this based on your system's configuration
#SBATCH --mem=100G  # Adjust this based on your memory requirements
#SBATCH --array=1-93%8
i=$SLURM_ARRAY_TASK_ID

# Set the path to the Kraken2 executable
Kraken2="/zfs/omics/projects/cevolution/software/kraken2"

# Set the path to the Kraken2 database
Kraken_DB="/zfs/evobiome/kraken_plusPf"

# Set input directory
Input_Dir="/zfs/omics/projects/cevolution/Trim"

# Set output directoy 
Output_Dir="/scratch/easy"
#"/home/irathma/personal/Projects/Metagenomics/0_abundancies"

ID=$(ls -1 $Input_Dir | grep "woCE_R1" | grep "R1" | sed -n ''$i'p' | cut -d"_" -f 1,2,3,4,5)

#IDlist=("Gent_iso_15_4_woCE\nWUR_bb_15_1_woCE\nNIOO_M00_1_1_woCE")
#ID=$(echo -e $IDlist |  sed -n ''$i'p')

IDout=$ID"_2plusPf"

# Run kraken through desired files
cd $Kraken2
./kraken2 --db $Kraken_DB --paired --gzip-compressed $Input_Dir/$ID"_R1.fastq.gz" $Input_Dir/$ID"_R2.fastq.gz" --report $Output_Dir/$IDout".IR.report" --output $Output_Dir/$IDout".IR.output"
#--unclassified-out $Output_Dir/$IDout"_unclass"#.fastq.gz
