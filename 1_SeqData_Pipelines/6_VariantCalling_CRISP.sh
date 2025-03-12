#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=CRISP
#-----------------------------Output files-----------------------------
#SBATCH --output=logs_slurm/output_%j.txt
#SBATCH --error=logs_slurm/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment='COMMENT'
#-----------------------------Required resources-----------------------
#SBATCH --time=240:00:00   # Adjust the time limit accordingly
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8  # Adjust this based on your system's configuration
#SBATCH --mem-per-cpu=10GB  # Adjust this based on your memory requirements
#SBATCH --array=1-7

i=$SLURM_ARRAY_TASK_ID

# specify paths
myBamPath="/zfs/omics/projects/cevolution/1_CnemEvol/3_CE_mapped/bam/new"
myOutPath="/zfs/omics/projects/cevolution/1_CnemEvol/4_PopAnalysis_IR/CRISP"
myIdxPath="/zfs/omics/projects/cevolution/dictionaries/Celegans"
RegionsPath=$myOutPath

# specify tool paths
CRISPpath="/zfs/omics/projects/cevolution/software/crisp-master/bin"

# define variables and names
### Set file names
ref_index="WBcel235_ref"
RegionName="WBcel235_ref.fasta.ChrNamesPart1"

### output name!
IDnameOut="CnemSamples_CRISP"

chrHere=$(cat $RegionsPath/$RegionName | sed -n ''$i'p')

# because it takes too long, parallelize by doing chromosome by chromosome and region by region
## the info is in the RegionName file

$CRISPpath/./CRISP.binary --bams $myOutPath/$IDnameOut"_BamList.txt" --ref $myIdxPath/$ref_index".fasta" --VCF $myOutPath/$IDnameOut"_Pool500_2"$chrHere".vcf" --poolsize 500 --regions $chrHere > $myOutPath/$IDnameOut"_Pool500_2"$chrHere"_variantcalls.log"

echo "Done calling!"
