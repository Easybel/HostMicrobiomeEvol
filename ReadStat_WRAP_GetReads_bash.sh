
## This script automatically runs the GetReads_fromFastq_Bam_JOB.sh script 
##      and before creates the needed output file

# what it needs: 
## -- path and file names specified in the file config.sh in the main path
Mainpath="/home/irathma/scripts"

# what it does:

# 1. read in the config file:
set -a
. $Mainpath/ReadStat_config.sh 
set +a

# 2. creates an empty file to write in and writes header
touch $pathOut/$newFile
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "IDhere" "RawReads1" "RawReads2" "TrimReads1" "TrimReads2" "CEReads1" "CEReads2" "CEReadsS" "woCEReads1" "woCEReads2" "woCEReadsS" "allLines" "allReads" "uMap" "uMapPair" "MapPair" "MappPair" > $pathOut/$newFile

# 3. starts the bash script
echo "Starting the job ..."
sbatch $Mainpath/ReadStat_FromFastq_Bam_JOB.sh
