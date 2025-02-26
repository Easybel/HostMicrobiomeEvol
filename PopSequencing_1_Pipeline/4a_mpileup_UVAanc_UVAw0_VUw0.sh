#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=snp_sync
#-----------------------------Output files-----------------------------
#SBATCH --output=logs_slurm/output_%j.txt
#SBATCH --error=logs_slurm/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment='DK angsd'
#-----------------------------Required resources-----------------------
#SBATCH --time=3-12:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=35G


## Basic pipeline for SNP identification
# set Condition paths
myIdxPath="/zfs/omics/projects/cevolution/dictionaries/Celegans"
myBamPath="/zfs/omics/projects/cevolution/CE_mapped/bam"
myOutPath="/scratch/easy"

## software path
myPopPath="zfs/omics/projects/cevolution/software/popoolation2_1201"

# set file names
ref_index="WBcel235_ref"
IDnameOut="UVAanc_UVAw0_VUw0"

####################
# file preparation #
####################


#1. The raw reads for each sample of population were trimmed as described before
#   Raw reads were mapped to C. elegans to remove bacterial sequences and then converted back to reads
#   Sequences were again mapped. Quality filtering has not been done 

#2. A mpileup file was made for bam files of all backbone lines with two timepoints
# converted back to sync file with a minimum quality of 20
# Samtools version version 1.9 was used. popoolation2 software is from Kofler R, Pandey RV, Schlötterer C. PoPoolation2: identifying differentiation between populations using sequencing of pooled DNA samples (Pool-Seq). Bioinformatics. 2011;27(24):3435–6.

#2a. Make Bamlist
BamList="$myBamPath/UVA_anc_0_1_CE_mapped_compl.bam $myBamPath/UVA_anc_0_2_CE_mapped_compl.bam $myBamPath/UVA_anc_0_3_CE_mapped_compl.bam \
$myBamPath/UVA_bb_0_1_CE_mapped_compl.bam $myBamPath/VU_bb_0_1_CE_mapped_compl.bam \
$myBamPath/VU_bb_0_2_CE_mapped_compl.bam $myBamPath/VU_bb_0_3_CE_mapped_compl.bam \
$myBamPath/VU_bb_0_4_CE_mapped_compl.bam $myBamPath/VU_bb_0_5_CE_mapped_compl.bam \
$myBamPath/VU_bn50_0_1_CE_mapped_compl.bam $myBamPath/VU_bn50_0_2_CE_mapped_compl.bam \
$myBamPath/VU_bn50_0_3_CE_mapped_compl.bam $myBamPath/VU_bn50_0_4_CE_mapped_compl.bam \
$myBamPath/VU_bn50_0_5_CE_mapped_compl.bam $myBamPath/VU_bn5_0_1_CE_mapped_compl.bam \
$myBamPath/VU_bn5_0_2_CE_mapped_compl.bam $myBamPath/VU_bn5_0_3_CE_mapped_compl.bam \
$myBamPath/VU_bn5_0_4_CE_mapped_compl.bam"

#2b. run samtools mpileup to actually make the mpileup file
samtools mpileup -f $myIdxPath/$ref_index".fasta" $BamList -o $myOutPath/$IDnameOut".mpileup"

#2c. write the samples in the correct order into a file
#starting columns  of sync file
	#column 1 in sync file: chromosome
	#col2: position within the reference contig
	#col3: reference character
start_columns="chromosome position ref_character "
echo "This is the list of samples used to create the file:" > $myOutPath/$IDnameOut"_COLUMNS.txt"
echo $start_columns$BamList >> $myOutPath/$IDnameOut"_COLUMNS.txt"

