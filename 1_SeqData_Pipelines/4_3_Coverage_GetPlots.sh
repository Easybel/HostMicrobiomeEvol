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
#SBATCH --array=1-14%5
i=$SLURM_ARRAY_TASK_ID

### Note: in order to run a python script with pre-installed packages, activate the environment here before you call sbatch ...
##  source /zfs/omics/projects/cevolution/software/normal_env/bin/activate

## call the script:

## 3e_C_Coverage_Plot_RawDataHistogram.py #InPath #InFilePattern #outPlots #suffix

list='Gent_bb Gent_iso VU_bb VU_bn5_ VU_bn50_ NIOO_bb_ NIOO_A00_15_ NIOO_A00_1_ NIOO_M00_15 NIOO_M00_1_ WUR_bb_ WUR_bleach_ RUG_bb_ UVA_'
InFilePattern=$(echo $list | awk '{print $'$i'}')

## what are the variables:
### -- inPath and inFilePattern: is the path and pattern with which to find a list of file names. These samples will be plotted together then and for each separate sample also the different chromosomes will be plotted together 
###    because that would defeat the cause of making the file size smaller)
### -- outPlots: path tp where to put plots
### -- suffix: anything that is in the sample name except for sample ID and .txt

scripts="/zfs/omics/projects/cevolution/1_CnemEvol/scripts"
InPath="/zfs/omics/projects/cevolution/1_CnemEvol/3_CE_mapped/coverage/chr_wise/"
#InFilePattern="Gent_bb"
outPlots="/zfs/omics/projects/cevolution/1_CnemEvol/3_CE_mapped/coverage/O_plots/"
suffix="_CE_mapped_compl_cov_"

python $scripts/4_3a_Coverage_Plot_RawDataHistogram.py $InPath $InFilePattern $outPlots $suffix

