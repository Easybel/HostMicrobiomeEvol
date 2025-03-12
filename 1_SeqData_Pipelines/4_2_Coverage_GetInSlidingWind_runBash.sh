#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name="GetCov_Py"
#-----------------------------Output files-----------------------------
#SBATCH --output=logs_slurm/output_%j.txt
#SBATCH --error=logs_slurm/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment='DK angsd'
#-----------------------------Required resources-----------------------
#SBATCH --time=5:00:00   # Adjust the time limit accordingly
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1  # Adjust this based on your system's configuration
#SBATCH --mem=8G  # Adjust this based on your memory requirements
#SBATCH --array=1-93
i=$SLURM_ARRAY_TASK_ID

## call the script:

##    Coverage_GetInSlidingWindow #InPath #InFilename(without the endling and without the chr..) #OutPath #windowSize

## what are the variables:
### -- inFile: is the path and filename of the file from which we want to cut the columns
### -- windowSize: in what window should the coverage average be evaluated? (I am here not letting windows overlap,
###    because that would defeat the cause of making the file size smaller)
### -- out: path and name of the output sample


scripts="/zfs/omics/projects/cevolution/1_CnemEvol/scripts"
InPath="/zfs/omics/projects/ecolievo/irathma/2_CnemEvol_EPB/Worms_Cov/"
InFilename=$(ls -1 $InPath | grep "mapped_compl_cov_chr1" | sed -n ''$i'p' | cut -d"_" -f 1,2,3,4,5,6,7,8)

outPath="/zfs/omics/projects/ecolievo/irathma/2_CnemEvol_EPB/Worms_Cov/cov_sldWindow"
windowSize=10000


python $scripts/4_2a_Coverage_GetSlidingWind.py $InPath $InFilename $outPath $windowSize

