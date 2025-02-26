#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=Poop-AllFreqDiff
#-----------------------------Output files-----------------------------
#SBATCH --output=logs_slurm/output_%j.txt
#SBATCH --error=logs_slurm/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment='COMMENT'
#-----------------------------Required resources-----------------------
#SBATCH --time=48:00:00   # Adjust the time limit accordingly
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8  # Adjust this based on your system's configuration
#SBATCH --mem-per-cpu=16GB  # Adjust this based on your memory requirements

pilePath="/zfs/omics/projects/cevolution/CE_mapped/pileup"
outPath="/zfs/omics/projects/cevolution/PopAnalysis_IR/Popoolation/FisherTest"

# folder of tools
popoPath1="/zfs/omics/projects/cevolution/software/popoolation_1.2.2"
popoPath2="/zfs/omics/projects/cevolution/software/popoolation2_1201"

IDnameOut="UVAanc_UVAw0_VUw0.mpileup"


#########################################################################
#### Analyse the different things we can analyse in 1 script!! ###########

## Get the frequency difference
perl $popoPath2/snp-frequency-diff.pl --input $pilePath/$IDnameOut"_minQUAL20.sync" --output-prefix $outPath/$IDnameOut"_minQUAL20" --min-count 2 --min-coverage 4 --max-coverage 300

