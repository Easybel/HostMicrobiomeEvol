#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=Subsample_BAM
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
#SBATCH --mem-per-cpu=40GB  # Adjust this based on your memory requirements
#SBATCH --array=1-93   #adjust to amount samples!  

i=$SLURM_ARRAY_TASK_ID

#Define input and output paths.
myDataBam="/zfs/omics/projects/cevolution/1_CnemEvol/3_CE_mapped/bam"
myIdxPath="/zfs/omics/projects/cevolution/dictionaries/Celegans"
#myOutPath="/zfs/omics/projects/cevolution/1_CnemEvol/3_CE_mapped/bam/subsampled_BAM"
myOutPath="/zfs/evobiome/easy_March25" # temporary

ID=$(ls -1 $myDataBam  | grep "_CE_2CE_sort_woDup_filt.bam" | grep -v "bai" | sed -n ''$i'p'| cut -d'_' -f1,2,3,4,5,6)

## 0. decide what the number of reads is you want to sample down to
targetNum=20000000
# this is the minimal number that will lead to coverage of around 30 that should keep most samples

## 1. get the number of reads in the bam file that I want to subsample to calculate the fraction of reads I want to keep
readNum=$(samtools view -c $myDataBam/$ID"_sort_woDup_filt.bam")

## 2. Get the fraction of reads I want to keep
frac=$(awk -v a="$readNum" -v b="$targetNum" 'BEGIN{print b/a}')
echo $frac

## Idea behind subsampling a bam:
# - You have a certain number of reads and select a fraction (or a fixed number of reads) randomly from there. This will still retain the coverage pattern across the genome, so really high-coverage regions will most likely still be covered a lot afterwards, but it will netto look as if they were sequenced to the same depth. 
# what does this mean for low covered samples: it will mean that low-covered regions are also downsampled. These regions will probably be filtered out in further analysis. This means we loose regions, so we maybe loose biological signal, but also we don't measure wrong signals. 

###########################################################################################################
## different options I found:
##
##
### 1. with samtools
#samtools view -h -s $frac $myDataBam/$ID"_sort_woDup_filt.bam" > $myOutPath/$ID"_sort_woDup_filt_Sub30XSAM.bam"

#sort bam files based on coordinates and index
#samtools sort $myOutPath/$ID"_sort_woDup_filt_Sub30XSAM.bam" -o $myOutPath/$ID"_sort_woDup_filt_Sub30XSAM_sort.bam"
#samtools index $myOutPath/$ID"_sort_woDup_filt_Sub30XSAM_sort.bam"


## DECISION: I will go with picard :) Because Neda mentioned it ######################################### 

#####################
##
##
### 2. with picard (Neda Barghi suggested and also used this)
/zfs/omics/software/bin/picard DownsampleSam -I $myDataBam/$ID"_sort_woDup_filt.bam" -O $myOutPath/$ID"_sort_woDup_filt_Sub30XPIC.bam" -STRATEGY HighAccuracy -P $frac -ACCURACY 0.001

#sort bam files based on coordinates and index
samtools sort $myOutPath/$ID"_sort_woDup_filt_Sub30XPIC.bam" -o $myOutPath/$ID"_sort_woDup_filt_Sub30XPIC_sort.bam"
samtools index $myOutPath/$ID"_sort_woDup_filt_Sub30XPIC_sort.bam"

rm $myOutPath/$ID"_sort_woDup_filt_Sub30XPIC.bam"
