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
#SBATCH --cpus-per-task=8  # Adjust this based on your system's configuration
#SBATCH --mem-per-cpu=16GB  # Adjust this based on your memory requirements
#SBATCH --array=1-16%3   #adjust to amount samples!  
i=$SLURM_ARRAY_TASK_ID

#Define input and output paths.
myDataTrim="/zfs/omics/projects/cevolution/Trim"
myIdxPath="/zfs/omics/projects/cevolution/dictionaries/Celegans"
myBamPath="/scratch/easy"

# Set file names
ref_index="WBcel235_ref" # Change this to your reference index (already indexed reference genome)

#in order to loop, automatically get the file names following some rules
ID=$(ls -1 $myDataTrim | grep "_1P.fastq.gz" | grep -v "NIOO" | grep -v "Gent" | grep -v "VU" | grep -v "WUR" | grep -v "UVA" | grep -v "RUG" | sed -n ''$i'p'| cut -d"_" -f1)


IDout=$ID"_2CE" 

#index reference genome
#already done! (with bwa index)

# Mapping with BWA - and convert to bam to save space
bwa mem -t $SLURM_CPUS_PER_TASK $myIdxPath/$ref_index".fasta" $myDataTrim/$ID"_1P.fastq.gz" $myDataTrim/$ID"_2P.fastq.gz" |\
 samtools view --threads 1 -bS - -o $myBamPath/$IDout".bam"
  
# get only alignments with a quality higher 20 (Thomas)  
samtools view -bq 20 $myBamPath/$IDout".bam" > $myBamPath/$IDout"_Q20.bam"  
 
#sort bam files based on coordinates 
samtools sort $myBamPath/$IDout"_Q20.bam" -o $myBamPath/$IDout"_Q20sort.bam"

#remove duplicate reads with Picard https://gatk.broadinstitute.org/hc/en-us/articles/360037052812-MarkDuplicates-Picard 
# -I input file SAM, BAM or CRAN. must be coordinate sorted !
# -M file to write duplication metrics
# -O output file to write the marked records
# -- REMOVE_DUPLICATES -> removes the found duplicates
/zfs/omics/software/bin/picard MarkDuplicates -I $myBamPath/$IDout"_Q20sort.bam" -M $myBamPath/$IDout"_marked_dup_metics" -O $myBamPath/$IDout"_Q20sort_woDUP.bam" --REMOVE_DUPLICATES

#index bam file
samtools index $myBamPath/$IDout"_Q20sort_woDUP.bam"

#collect alignment & insert size metrics (https://gencore.bio.nyu.edu/variant-calling-pipeline-gatk4/)
#tools: Picard Tools, R, Samtools
# -R = reference genome 
# -I = sorted bam file
# -O = alignment_metrics.txt
/zfs/omics/software/bin/picard CollectAlignmentSummaryMetrics R=$myIdxPath/$ref_index".fasta" I=$myBamPath/$IDout"_Q20sort_woDUP.bam" O=$myBamPath/$IDout"_AlignSummary.txt"


# INPUT: sorted bam file
# OUTPUT: insert metrics.txt
# HISTOGRAM_FILE: insert_size_histogram.pdf
/zfs/omics/software/bin/picard CollectInsertSizeMetrics \
      I=$myBamPath/$IDout"_Q20sort_woDUP.bam" \
      O=$myBamPath/$IDout"insert_size_metrics.txt" \
      H=$myBamPath/$IDout"insert_size_histogram.pdf"
      
# -a = sorted bam file   
samtools depth -a $myBamPath/$IDout"_Q20sort_woDUP.bam" > $myBamPath/$IDout"_Q20depth.txt"

