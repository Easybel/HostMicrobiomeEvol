#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=copy_stuff
#-----------------------------Output files-----------------------------
#SBATCH --output=logs_slurm/output_%j.txt
#SBATCH --error=logs_slurm/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment='DK angsd'
#-----------------------------Required resources-----------------------
#SBATCH --time=24:00:00   # Adjust the time limit accordingly
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1  # Adjust this based on your system's configuration
#SBATCH --mem-per-cpu=500MB  # Adjust this based on your memory requirements 

# Set the paths
loc_init="/zfs/omics/projects/ecolievo/irathma/fromEmmaDiepeveen/VCF"
loc_final="/zfs/omics/projects/cevolution/1_CnemEvol/5_VCF_fromEmma"

#cd $loc_init
cp $loc_init/* $loc_final
echo "Done with copying!"

exit
