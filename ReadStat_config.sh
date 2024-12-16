##the Config File for the ReadStatistics steps: 

## --  Here, only path and names are defined that will be needed in both scripts, the WRAP.. and the JOB script


# define paths and names
Mainpath="/home/irathma/scripts" # this is where the config file is

pathBam="/zfs/omics/projects/cevolution/Out/bam"
pathRawfq="/zfs/omics/projects/cevolution/Raw"
pathTrimfq="/zfs/omics/projects/cevolution/Trim"
pathOut="/home/irathma/scripts"

# Get file names
newFile="Readstat_collect_20240314.txt"

IDlist=$(ls -1 $pathBam | grep "sort.bam" |sed -n ''$i'p' | cut -d"_" -f1,2,3,4 )
