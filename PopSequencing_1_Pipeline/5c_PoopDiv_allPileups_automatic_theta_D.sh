#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=Theta_D_allSamples
#-----------------------------Output files-----------------------------
#SBATCH --output=logs_slurm/output_%j.txt
#SBATCH --error=logs_slurm/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment='COMMENT'
#-----------------------------Required resources-----------------------
#SBATCH --time=72:00:00   # Adjust the time limit accordingly
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1  # Adjust this based on your system's configuration
#SBATCH --mem-per-cpu=250MB  # Adjust this based on your memory requirements
#SBATCH --array=1-91%15
i=$SLURM_ARRAY_TASK_ID

# paths!
pilePath="/zfs/omics/projects/ecolievo/irathma/PiDiversity/pileup_temp"
outPath="/zfs/omics/projects/cevolution/PopAnalysis_IR/Popoolation/Pi_Diversity/defaultSet_500Cov/fractioncov_0.01"

# folder of tools
popoPath1="/zfs/omics/projects/cevolution/software/popoolation_1.2.2"
popoPath2="/zfs/omics/projects/cevolution/software/popoolation2_1201"

SamName=$(ls -1 $pilePath | grep "pileup" | sed -n ''$i'p' | cut -d'_' -f1,2,3,4)

perl $popoPath1/Variance-sliding.pl --input $pilePath/$SamName"_temp.pileup" --output $outPath/$SamName"_Sanger_maxCov500_fracCov_0.01.D" --fastq-type sanger --measure D --window-size 10000 --step-size 10000 --min-count 2 --min-coverage 4 --max-coverage 500 --pool-size 500 --min-covered-fraction 0.01

perl $popoPath1/Variance-sliding.pl --input $pilePath/$SamName"_temp.pileup" --output $outPath/$SamName"_Sanger_maxCov500_fracCov_0.01.theta" --fastq-type sanger --measure theta --window-size 10000 --step-size 10000 --min-count 2 --min-coverage 4 --max-coverage 500 --pool-size 500 --min-covered-fraction 0.01


