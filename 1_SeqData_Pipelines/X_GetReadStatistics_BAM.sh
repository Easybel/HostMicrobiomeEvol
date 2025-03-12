#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name="GetRead_Statistics"
#-----------------------------Output files-----------------------------
#SBATCH --output=logs_slurm/output_%j.txt
#SBATCH --error=logs_slurm/error_output_%j.txt

#-----------------------------Other information------------------------
#SBATCH --comment='COMMENT'
#-----------------------------Required resources-----------------------
#SBATCH --time=24:00:00   # Adjust the time limit accordingly
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8  # Adjust this based on your system's configuration
#SBATCH --mem-per-cpu=16GB  # Adjust this based on your memory requirements


# this script goes through the samples in a folder specified by ID and gets all the read information for that:

BamFolder="/zfs/omics/projects/cevolution/1_CnemEvol/3_CE_mapped/bam/new"
outFolder="/zfs/omics/projects/cevolution/1_CnemEvol/3_CE_mapped/bam/new"
outName="Readstats_fromBam_20250305_new.txt"

touch $outFolder/$outName
header="#line all uMap uMapPair MapPair MappPair ReadswoDup ReadswoDup_Filt"

echo $header > $OutFolder/$outName

#IDlist=$(ls -1 $BamFolder |grep 'bam' | grep -v "bai" | grep "sort" | rev | cut -d"." -f2 | rev)
IDlist=$(ls -1 $BamFolder |grep 'bam' | grep -v "bai" | grep "sort_woDup_filt" | cut -d"_" -f1,2,3,4,5,6)

#### get:

## LOOP LOOP LOOP LOOP

# define current name
for file in $IDlist; do

#samtools view -bS $folder/$file".sam" -o $folder/$file".bam"

IDhere=$file

# numer of alignments: "line"
line=$(samtools view $BamFolder/$IDhere".bam" | wc -l)

# number of reads: "all"
all=$(samtools view -c -F 256 -F 2048 $BamFolder/$IDhere".bam")

# number of unmapped reads
uMap=$(samtools view -c -f 4 -F 256 $BamFolder/$IDhere".bam")

# number of unmapped, paired reads
uMapPair=$(samtools view -c -f 13 -F 256 $BamFolder/$IDhere".bam")

# number of mapped, paired reads
MapPair=$(samtools view -c -f 1 -F 4 -F 256 $BamFolder/$IDhere".bam")

# number of mapped, properly paired reads
MappPair=$(samtools view -c -f 3 -F 4 -F 256 $BamFolder/$IDhere".bam")

# reads after removinf duplicates
ReadswoDup=$(samtools view -c $BamFolder/$IDhere"_sort_woDup.bam")

# reads after removinf duplicates
ReadswoDup_Filt=$(samtools view -c $BamFolder/$IDhere"_sort_woDup_filt.bam")

printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$IDhere" "$line" "$all" "$uMap" "$uMapPair" "$MapPair" "$MappPair" "$ReadswoDup" "$ReadswoDup_Filt" >> $outFolder/$outName

done
