#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=subsampling
#-----------------------------Output files-----------------------------
#SBATCH --output=logs_slurm/output_%j.txt
#SBATCH --error=logs_slurm/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment='DK angsd'
#-----------------------------Required resources-----------------------
#SBATCH --time=3-00:00:00   # Adjust the time limit accordingly
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8  # Adjust this based on your system's configuration
#SBATCH --mem-per-cpu=12G  # Adjust this based on your memory requirements 

#subsampling with popooplation

myPopPath="/zfs/omics/projects/cevolution/software/popoolation2_1201"
myInPath="/zfs/omics/projects/cevolution/SNP_identification"

perl $myPopPath/subsample-synchronized.pl --input $myInPath/CE_BB_wk1_wk15_Q20.sync --output $myInPath/CE_BB_wk1_wk15_Q20_35X.sync --target-coverage 35 --max-coverage 2%  --method withoutreplacement

