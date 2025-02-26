#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=Subsample_Pi
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
#SBATCH --mem-per-cpu=200MB  # Adjust this based on your memory requirements
#SBATCH --array=1-38%10
i=$SLURM_ARRAY_TASK_ID

### here subsample for the defined parameters

## ## ## Parameters for subsampling
SizeSubSamples=100	# how many reads to subsample per position
NumSubSamples=5 	# how often do we want to make a subsample

# paths!
infoPath="/zfs/omics/projects/cevolution/CE_mapped/pileup"
pilePath="/zfs/omics/projects/ecolievo/irathma/PiDiversity/pileup_temp"
outPath="/zfs/omics/projects/cevolution/PopAnalysis_IR/Popoolation/Pi_Diversity/subSample_pool500"

# folder of tools
popoPath1="/zfs/omics/projects/cevolution/software/popoolation_1.2.2"
popoPath2="/zfs/omics/projects/cevolution/software/popoolation2_1201"

StartFile="BB_wk1_wk15"
# file where the names and indices are:
infoFile=$infoPath/$StartFile"_COLUMNS_4pileup.txt"
# get the name of the sample and the columns that are needed for the pileup
SamName=$(cat $infoFile | sed -n ''$i'p' | cut -d' ' -f1)
idxColumns=$(cat $infoFile | sed -n ''$i'p' | cut -d' ' -f2)
#SamName=$(ls -1 /scratch/easy | grep "pileup" | sed -n ''$i'p' | cut -d'_' -f1,2,3,4)


#loop over the number of all NumSubSample!!!
for idx in $(seq 1 $NumSubSamples); do 

SamNameOut=$SamName"_sub"$SizeSubSamples"_"$idx
echo $SamNameOut

#########################################################################
#### Analyse the different things we can analyse in 1 script!! ###########

## Get the vari with a python script

## subsample the pileup of this sample!
perl $popoPath1/basic-pipeline/subsample-pileup.pl --input $pilePath/$SamName"_temp.pileup" --output /scratch/$SamNameOut".pileup" --target-coverage $SizeSubSamples --max-coverage 500 --min-qual 20 --method withoutreplace --fastq-type sanger


perl $popoPath1/Variance-sliding.pl --input /scratch/$SamNameOut".pileup" --output $outPath/$SamNameOut"_Sanger_maxCov500.pi" --fastq-type sanger --measure pi --window-size 10000 --step-size 10000 --min-count 2 --min-coverage 4 --max-coverage 500 --pool-size 500 --min-covered-fraction 0.01

rm /scratch/$SamNameOut".pileup"
done
