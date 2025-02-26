#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=PoopDiv_Pi
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
#SBATCH --array=1-20%5
i=$SLURM_ARRAY_TASK_ID

# paths!
pilePath="/zfs/omics/projects/cevolution/CE_mapped/pileup"
outPath="/zfs/omics/projects/cevolution/PopAnalysis_IR/Popoolation/Pi_Diversity"

# folder of tools
popoPath1="/zfs/omics/projects/cevolution/software/popoolation_1.2.2"
popoPath2="/zfs/omics/projects/cevolution/software/popoolation2_1201"

StartFile="VUw0_VUw1_VUw15_BB"
# file where the names and indices are:
infoFile=$pilePath/$StartFile"_COLUMNS_4pileup.txt"
# get the name of the sample and the columns that are needed for the pileup
SamName=$(cat $infoFile | sed -n ''$i'p' | cut -d' ' -f1)
idxColumns=$(cat $infoFile | sed -n ''$i'p' | cut -d' ' -f2)

#########################################################################
#### Analyse the different things we can analyse in 1 script!! ###########

## Get the vari with a python script
#python /zfs/omics/projects/cevolution/scripts/cut_columns.py /zfs/omics/projects/cevolution/CE_mapped/pileup/UVAanc_UVAw0_VUw0.mpileup 1,2,3,4,5,6 /zfs/omics/projects/cevolution/CE_mapped/pileup/Test_Mai7.pileup

cut -f $idxColumns $pilePath/$StartFile".mpileup" > /scratch/easy/$SamName"_temp.pileup" 
#awk -v column="$idxColumns" '{print $column}' $pilePath/$ID".mpileup" > /scratch/easy/$SamName"_temp.pileup"

perl $popoPath1/Variance-sliding.pl --input /scratch/easy/$SamName"_temp.pileup" --output $outPath/$SamName".pi" --measure pi --window-size 10000 --step-size 10000 --min-count 2 --min-coverage 4 --max-coverage 300 --min-qual 20 --pool-size 500 

