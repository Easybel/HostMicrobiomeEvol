#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=snp_sync
#-----------------------------Mail address-----------------------------
#SBATCH --mail-type=ALL
#-----------------------------Output files-----------------------------
#SBATCH --output=logs_slurm/output_%j.txt
#SBATCH --error=logs_slurm/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment='DK angsd'
#-----------------------------Required resources-----------------------
#SBATCH --time=11-00:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=35G


## Basic pipeline for SNP identification
# set Condition paths
myIdxPath="/zfs/omics/projects/cevolution/dictionaries/Celegans"
myBamPath="/zfs/omics/projects/cevolution/CE_mapped/bam"
myOutPath="/zfs/omics/projects/cevolution/SNP_identification"
myPopPath="/zfs/omics/projects/cevolution/software/popoolation2_1201"


# set file names
ref_index="WBcel235_ref"
IDnameOut="CE_BB_wk1_wk15"

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
BamList="$myBamPath/Gent_bb_1_1_CE_mapped_compl.bam $myBamPath/Gent_bb_15_1_CE_mapped_compl.bam \
$myBamPath/Gent_bb_1_2_CE_mapped_compl.bam $myBamPath/Gent_bb_15_2_CE_mapped_compl.bam \
$myBamPath/Gent_bb_1_3_CE_mapped_compl.bam $myBamPath/Gent_bb_15_3_CE_mapped_compl.bam \
$myBamPath/Gent_bb_1_4_CE_mapped_compl.bam $myBamPath/Gent_bb_15_4_CE_mapped_compl.bam \
$myBamPath/NIOO_bb_1_1_CE_mapped_compl.bam $myBamPath/NIOO_bb_15_1_CE_mapped_compl.bam \
$myBamPath/NIOO_bb_1_3_CE_mapped_compl.bam $myBamPath/NIOO_bb_15_3_CE_mapped_compl.bam \
$myBamPath/NIOO_bb_1_4_CE_mapped_compl.bam $myBamPath/NIOO_bb_15_4_CE_mapped_compl.bam \
$myBamPath/RUG_bb_1_1_CE_mapped_compl.bam $myBamPath/RUG_bb_15_1_CE_mapped_compl.bam \
$myBamPath/RUG_bb_1_2_CE_mapped_compl.bam $myBamPath/RUG_bb_15_2_CE_mapped_compl.bam \
$myBamPath/RUG_bb_1_4_CE_mapped_compl.bam $myBamPath/RUG_bb_15_4_CE_mapped_compl.bam \
$myBamPath/RUG_bb_1_5_CE_mapped_compl.bam $myBamPath/RUG_bb_15_5_CE_mapped_compl.bam \
$myBamPath/VU_bb_1_1_CE_mapped_compl.bam $myBamPath/VU_bb_15_1_CE_mapped_compl.bam \
$myBamPath/VU_bb_1_2_CE_mapped_compl.bam $myBamPath/VU_bb_15_2_CE_mapped_compl.bam \
$myBamPath/VU_bb_1_3_CE_mapped_compl.bam $myBamPath/VU_bb_15_3_CE_mapped_compl.bam \
$myBamPath/VU_bb_1_4_CE_mapped_compl.bam $myBamPath/VU_bb_15_4_CE_mapped_compl.bam \
$myBamPath/VU_bb_1_5_CE_mapped_compl.bam $myBamPath/VU_bb_15_5_CE_mapped_compl.bam \
$myBamPath/WUR_bb_1_1_CE_mapped_compl.bam $myBamPath/WUR_bb_15_1_CE_mapped_compl.bam \
$myBamPath/WUR_bb_1_2_CE_mapped_compl.bam $myBamPath/WUR_bb_15_2_CE_mapped_compl.bam \
$myBamPath/WUR_bb_1_3_CE_mapped_compl.bam $myBamPath/WUR_bb_15_3_CE_mapped_compl.bam"


#2b. run samtools mpileup to actually make the mpileup file
#samtools mpileup -f $myIdxPath/$ref_index".fasta" $BamList -o $myOutPath/$IDnameOut".mpileup"
#samtools mpileup -f $myIdxPath/$ref_index".fasta" $BamList | java -Xmx20g -jar $myPopPath/mpileup2sync.jar --input /dev/stdin --output $myOutPath/$IDnameOut"_Q20.sync" --fastq-type sanger --min-qual 20 --threads 12

#2c. write the samples in the correct order into a file
#starting columns  of sync file
	#column 1 in sync file: chromosome
	#col2: position within the reference contig
	#col3: reference character
#start_columns="chromosome position ref_character "
#echo "This is the list of samples used to create the file:" > $myOutPath/$IDnameOut"_COLUMNS.txt"
#echo $start_columns$BamList >> $myOutPath/$IDnameOut"_COLUMNS.txt"


#3. Convert mpileup file in sync file (done separately so that mpileup file can be manipulated later if needed!)
#java -ea -Xmx7g -jar $myPopPath/mpileup2sync.jar --input $myOutPath/$IDnameOut".mpileup" --output $myOutPath/$IDnameOut"_Q20_2.sync" --fastq-type sanger --min-qual 20 --threads 12

#####################
#Fisher's exact test#
#####################
# Prepare the name list file 
# If directly from the #BamList the order of the sample names changes, so via the 
#bam_name=$(head -n 1 $myOutPath/$IDnameOut"_COLUMNS.txt") 
#samplelist=$(ls -1 $bam_name | grep 'zfs' $bam_name | cut -d "/" -f8 | cut -d "_" -f1,2,3,4)
#sample_list=($start_columns$samplelist)

#5. Run Fisher's exact test (FET) on all 19 evolved replicates 
#5a. Separate week1 and week15 samples for each replicate in a separate file
#cut -f 1-4,5 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[3]}""_rep".sync
#cut -f 1-3,6,7 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[5]}""_rep".sync
#cut -f 1-3,8,9 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[7]}""_rep".sync
#cut -f 1-3,10,11 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[9]}""_rep".sync
#cut -f 1-3,12,13 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[11]}""_rep".sync
#cut -f 1-3,14,15 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[13]}""_rep".sync
#cut -f 1-3,16,17 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[15]}""_rep".sync
#cut -f 1-3,18,19 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[17]}""_rep".sync
#cut -f 1-3,20,21 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[19]}""_rep".sync
#cut -f 1-3,22,23 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[21]}""_rep".sync
#cut -f 1-3,24,25 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[23]}""_rep".sync
#cut -f 1-3,26,27 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[25]}""_rep".sync
#cut -f 1-3,28,29 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[27]}""_rep".sync
#cut -f 1-3,30,31 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[29]}""_rep".sync
#cut -f 1-3,32,33 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[31]}""_rep".sync
#cut -f 1-3,34,35 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[33]}""_rep".sync
#cut -f 1-3,36,37 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[35]}""_rep".sync
#cut -f 1-3,38,39 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[37]}""_rep".sync
#cut -f 1-3,40,41 $myOutPath/$IDnameOut"_Q20.sync" > $myOutPath/fishers_test/"${sample_list[39]}""_rep".sync



#7b. actually run FET 
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[3]}""_rep".sync --output $myOutPath/fishers_test/Gent_bb_wk1_wk15_rep1.sync.fet --min-count 5 --min-coverage 10 --max-coverage 450
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[5]}""_rep".sync --output $myOutPath/fishers_test/Gent_bb_wk1_wk15_rep2.sync.fet --min-count 5 --min-coverage 7 --max-coverage 477
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[7]}""_rep".syncc --output $myOutPath/fishers_test/Gent_bb_wk1_wk15_rep3.sync.fet --min-count 5 --min-coverage 8 --max-coverage 582
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[9]}""_rep".sync --output $myOutPath/fishers_test/Gent_bb_wk1_wk15_rep4.sync.fet --min-count 5 --min-coverage 8 --max-coverage 635
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[11]}""_rep".sync --output $myOutPath/fishers_test/NIOO_bb_wk1_wk15_rep1.sync.fet --min-count 5 --min-coverage 4 --max-coverage 309
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[13]}""_rep".sync --output $myOutPath/fishers_test/NIOO_bb_wk1_wk15_rep3.sync.fet --min-count 5 --min-coverage 4 --max-coverage 376
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[15]}""_rep".sync --output $myOutPath/fishers_test/NIOO_bb_wk1_wk15_rep4.sync.fet --min-count 5 --min-coverage 4 --max-coverage 439
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[17]}""_rep".sync --output $myOutPath/fishers_test/RUG_bb_wk1_wk15_rep1.sync.fet --min-count 5 --min-coverage 7 --max-coverage 580
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[19]}""_rep".sync --output $myOutPath/fishers_test/RUG_bb_wk1_wk15_rep2.sync.fet --min-count 5 --min-coverage 9 --max-coverage 562
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[21]}""_rep".sync --output $myOutPath/fishers_test/RUG_bb_wk1_wk15_rep4.sync.fet --min-count 5 --min-coverage 8 --max-coverage 525
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[23]}""_rep".sync --output $myOutPath/fishers_test/RUG_bb_wk1_wk15_rep5.sync.fet --min-count 5 --min-coverage 8 --max-coverage 555
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[25]}""_rep".sync --output $myOutPath/fishers_test/VU_bb_wk1_wk15_rep1.sync.fet --min-count 5 --min-coverage 7 --max-coverage 507
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[27]}""_rep".sync --output $myOutPath/fishers_test/VU_bb_wk1_wk15_rep2.sync.fet --min-count 5 --min-coverage 6 --max-coverage 630
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[29]}""_rep".sync --output $myOutPath/fishers_test/VU_bb_wk1_wk15_rep3.sync.fet --min-count 5 --min-coverage 6 --max-coverage 525
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[31]}""_rep".sync --output $myOutPath/fishers_test/VU_bb_wk1_wk15_rep4.sync.fet --min-count 5 --min-coverage 6 --max-coverage 553
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[33]}""_rep".sync --output $myOutPath/fishers_test/VU_bb_wk1_wk15_rep5.sync.fet --min-count 5 --min-coverage 7 --max-coverage 613
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[35]}""_rep".sync --output $myOutPath/fishers_test/WUR_bb_wk1_wk15_rep1.sync.fet --min-count 5 --min-coverage 8 --max-coverage 632
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[37]}""_rep".sync --output $myOutPath/fishers_test/WUR_bb_wk1_wk15_rep2.sync.fet --min-count 5 --min-coverage 7 --max-coverage 592
#perl $myPopPath/fisher-test.pl --input $myOutPath/fishers_test/"${sample_list[39]}""_rep".sync --output $myOutPath/fishers_test/WUR_bb_wk1_wk15_rep3.sync.fet --min-count 5 --min-coverage 7 --max-coverage 591


#perl $myPopPath/export/pwc2igv.pl --input $myOutPath/fishers_test/RUG_bb_wk1_wk15_rep1.sync.fet --output $myOutPath/fishers_test/RUG_bb_wk1_wk15_rep1_fet.igv
#perl $myPopPath/export/pwc2igv.pl --input $myOutPath/fishers_test/RUG_bb_wk1_wk15_rep2.sync.fet --output $myOutPath/fishers_test/RUG_bb_wk1_wk15_rep2_fet.igv
#perl $myPopPath/export/pwc2igv.pl --input $myOutPath/fishers_test/RUG_bb_wk1_wk15_rep3.sync.fet --output $myOutPath/fishers_test/RUG_bb_wk1_wk15_rep3_fet.igv
#perl $myPopPath/export/pwc2igv.pl --input $myOutPath/fishers_test/RUG_bb_wk1_wk15_rep4.sync.fet --output $myOutPath/fishers_test/RUG_bb_wk1_wk15_rep4_fet.igv


#cut -f1 $myOutPath/BB_wk1_wk15.mpileup | sort | uniq > $myOutPath/chrom.txt
