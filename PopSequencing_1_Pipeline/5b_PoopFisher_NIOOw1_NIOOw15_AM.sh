#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=Poop_Fish
#-----------------------------Output files-----------------------------
#SBATCH --output=logs_slurm/output_%j.txt
#SBATCH --error=logs_slurm/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment='COMMENT'
#-----------------------------Required resources-----------------------
#SBATCH --time=48:00:00   # Adjust the time limit accordingly
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1  # Adjust this based on your system's configuration
#SBATCH --mem-per-cpu=2GB  # Adjust this based on your memory requirements
#SBATCH --array=1-9%5
i=$SLURM_ARRAY_TASK_ID

# paths!
pilePath="/zfs/omics/projects/cevolution/CE_mapped/pileup"
outPath="/zfs/omics/projects/cevolution/PopAnalysis_IR/Popoolation/FisherTest"

# folder of tools
popoPath1="/zfs/omics/projects/cevolution/software/popoolation_1.2.2"
popoPath2="/zfs/omics/projects/cevolution/software/popoolation2_1201"

StartFile="NIOOw1_NIOOw15_AM"
# file where the names and indices are:
infoFile=$pilePath/$StartFile"_COLUMNS_4sync_FisherPairs.txt"
# get the name of the sample and the columns that are needed for the pileup
SamName=$(cat $infoFile | sed -n ''$i'p' | cut -d' ' -f1)
idxColumns=$(cat $infoFile | sed -n ''$i'p' | cut -d' ' -f2)

#########################################################################
#### Analyse the different things we can analyse in 1 script!! ###########

cut -f $idxColumns $pilePath/$StartFile".mpileup_minQUAL20.sync" > /scratch/$SamName"_temp.sync" 

perl $popoPath2/fisher-test.pl --input /scratch/$SamName"_temp.sync" --output $outPath/$SamName".fet" --min-count 2 --min-coverage 4 --max-coverage 500 --suppress-noninformative

