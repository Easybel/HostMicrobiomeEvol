#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=Cov-PerChr
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
#SBATCH --array=1-93%20   #adjust to amount samples!  
i=$SLURM_ARRAY_TASK_ID

#Define input and output paths.
myCovPath="/zfs/omics/projects/ecolievo/irathma/Worms_Cov/cov_minQual20"
outPath="/zfs/omics/projects/ecolievo/irathma/Worms_Cov/cov_minQual20/perChr"

#in order to loop, automatically get the file names following some rules
ID=$(ls -1 $myCovPath | grep "cov" | sed -n ''$i'p'| cut -d"." -f1)

# get a separate coverage file for each chromosome!!

grep "NC_003279.8" $myCovPath/$ID".txt" > $outPath/$ID"_chr1.txt"
grep "NC_003280.10" $myCovPath/$ID".txt" > $outPath/$ID"_chr2.txt"
grep "NC_003281.10" $myCovPath/$ID".txt" > $outPath/$ID"_chr3.txt"
grep "NC_003282.8" $myCovPath/$ID".txt" > $outPath/$ID"_chr4.txt"
grep "NC_003283.11" $myCovPath/$ID".txt" > $outPath/$ID"_chr5.txt"
grep "NC_003284.9" $myCovPath/$ID".txt" > $outPath/$ID"_chr6.txt"
grep "NC_001328.1" $myCovPath/$ID".txt" > $outPath/$ID"_chr7.txt"

