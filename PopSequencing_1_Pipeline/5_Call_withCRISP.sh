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
myBamPath="/zfs/omics/projects/cevolution/CE_mapped/bam"
myOutPath="/zfs/omics/projects/cevolution/popGen_IR/CRISP"
myIdxPath="/zfs/omics/projects/cevolution/dictionaries/Celegans"

# specify tool paths
CRISPpath="/zfs/omics/projects/cevolution/software/crisp-master/bin"

# define variables and names
### Set file names
ref_index="WBcel235_ref"
chrNames="WBcel235_ref.fasta.ChrNames"

### output name!
IDnameOut="CnemEvolution_all_CRISP"

chrHere=$(cat $myIdxPath/$chrNames | sed -n ''$i'p')

# 1a. Make Bamlist

# 1b. write the samples in the correct order into a file
#starting columns  of sync file
        #column 1 in sync file: chromosome
        #col2: position within the reference contig
        #col3: reference character
#start_columns="chromosome position ref_character "
#echo "This is the list of samples used to create the file:" > $myOutPath/$IDnameOut"_COLUMNS.txt"
#echo $BamList > $myOutPath/$IDnameOut"_BamList.txt"

# because it takes too long, parallelize by doing chromosome by chromosome 
$CRISPpath/./CRISP.binary --bams $myOutPath/$IDnameOut"_BamList.txt" --ref $myIdxPath/$ref_index".fasta" --VCF $myOutPath/$IDnameOut"_Pool300_2"$chrHere".vcf" --poolsize 300 --regions $chrHere > $myOutPath/$IDnameOut"_Pool300_2"$chrHere"_variantcalls.log"

echo "Done calling!"
