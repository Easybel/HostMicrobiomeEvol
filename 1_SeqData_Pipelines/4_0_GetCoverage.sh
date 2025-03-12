#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=Map-onlyCE
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
#SBATCH --mem-per-cpu=100MB  # Adjust this based on your memory requirements
#SBATCH --array=1-93%10   #adjust to amount samples!  
i=$SLURM_ARRAY_TASK_ID

#Define input and output paths.
myBamPath="/zfs/omics/projects/cevolution/CE_mapped"

#in order to loop, automatically get the file names following some rules
ID=$(ls -1 $myBamPath/bam | grep "compl.bam" | grep -v "bai" | grep -v "readgroups" | sed -n ''$i'p'| cut -d"." -f1)

# -a = sorted bam file   
samtools depth -a -Q 20 $myBamPath/bam/$ID".bam" > /zfs/omics/projects/ecolievo/irathma/Worms_Cov/cov_minQual20/$ID"_cov_minQual20.txt"

