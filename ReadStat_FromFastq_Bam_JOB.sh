#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name="GetRead_Statistics"
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
#SBATCH --mem-per-cpu=32GB  # Adjust this based on your memory requirements
#SBATCH --array=1-93
i=$SLURM_ARRAY_TASK_ID

Mainpath="/home/irathma/scripts"

echo $Mainpath

set -a
. $Mainpath/config.sh
set +a

# this script goes through the samples in a folder specified by ID and gets all the read information for that:

#### get:

ID=$IDlist

echo $Mainpath
echo $ID

# numer of alignments: "line"
echo "Running lines"
line=$(samtools view -@ 8 $pathBam/$ID"_2CE_all_sort.bam" | wc -l)
echo "lines="$line

echo "Running all"
# number of reads: "all"
all=$(samtools view -@ 8 -c -F 256 -F 2048 $pathBam/$ID"_2CE_all_sort.bam")
echo "all="$all

echo "Running unmapped"
# number of unmapped reads
uMap=$(samtools view -@ 8 -c -f 4 -F 256 -F 2048 $pathBam/$ID"_2CE_all_sort.bam")
echo "uMap="$uMap

echo "Runing unmapped and paired"
# number of unmapped, paired reads
uMapPair=$(samtools view -@ 8 -c -f 13 -F 256 -F 2048 $pathBam/$ID"_2CE_all_sort.bam")
echo "uMapPair="$uMapPair

echo "Running MapPair"
# number of mapped, paired reads
MapPair=$(samtools view -@ 8 -c -f 1 -F 4 -F 256 -F 2048 $pathBam/$ID"_2CE_all_sort.bam")
echo "MapPair="$MapPair

echo "MappPair"
# number of mapped, properly paired reads
MappPair=$(samtools view -@ 8 -c -f 3 -F 4 -F 256 -F 2048 $pathBam/$ID"_2CE_all_sort.bam")
echo "MappPair="$MappPair

RawReads1=$(zcat $pathRawfq/$ID"_R1.fastq.gz" | echo $((`wc -l`/4)))
RawReads2=$(zcat $pathRawfq/$ID"_R2.fastq.gz" | echo $((`wc -l`/4)))

TrimReads1=$(zcat $pathTrimfq/$ID"_1P.fastq.gz" | echo $((`wc -l`/4)))
TrimReads2=$(zcat $pathTrimfq/$ID"_2P.fastq.gz" | echo $((`wc -l`/4)))

CEReads1=$(zcat $pathTrimfq/$ID"_CE_R1.fastq.gz" | echo $((`wc -l`/4)))
CEReads2=$(zcat $pathTrimfq/$ID"_CE_R2.fastq.gz" | echo $((`wc -l`/4)))

CEReadsS=$(zcat $pathTrimfq/$ID"_CE_S.fastq.gz" | echo $((`wc -l`/4)))

woCEReads1=$(zcat $pathTrimfq/$ID"_woCE_R1.fastq.gz" | echo $((`wc -l`/4)))
woCEReads2=$(zcat $pathTrimfq/$ID"_woCE_R2.fastq.gz" | echo $((`wc -l`/4)))

woCEReadsS=$(zcat $pathTrimfq/$ID"_woCE_S.fastq.gz" | echo $((`wc -l`/4)))


echo "printing ...."
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$ID" "$RawReads1" "$RawReads2" "$TrimReads1" "$TrimReads2" "$CEReads1" "$CEReads2" "$CEReadsS" "$woCEReads1" "$woCEReads2" "$woCEReadsS" "$line" "$all" "$uMap" "$uMapPair" "$MapPair" "$MappPair" >> $pathOut/$newFile



