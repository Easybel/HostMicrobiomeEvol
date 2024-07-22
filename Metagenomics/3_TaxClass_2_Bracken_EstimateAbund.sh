#!/bin/bash
# -----------------------------Name of the job-------------------------
#SBATCH --job-name=BrackenEstimate
#-----------------------------Output files-----------------------------
#SBATCH --output=logs_slurm/output_%j.txt
#SBATCH --error=logs_slurm/error_output_%j.txt
#-----------------------------Other information------------------------
#SBATCH --comment='DK angsd'
#-----------------------------Required resources-----------------------
#SBATCH --time=2:00:00   # Adjust the time limit accordingly
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1  # Adjust this based on your system's configuration
#SBATCH --mem-per-cpu=5G  # Adjust this based on your memory requirements
#SBATCH --array=1-93 
i=$SLURM_ARRAY_TASK_ID

# specify where the db is
KRAKEN_DB="/zfs/evobiome/kraken_plusPf"

# specify where the reports are
Report_path="/home/irathma/personal/Projects/Metagenomics/0_abundancies/KraBracken"

# specify where the software is
KrakenFold="/zfs/omics/projects/cevolution/software/kraken2"
BrackenFold="/zfs/omics/projects/cevolution/software/Bracken-master"

ID=$(ls -1 $Report_path | grep "woCE_2plusPf.IR.report" | sed -n ''$i'p' | cut -d"." -f1,2)

$BrackenFold/./bracken -d $KRAKEN_DB -i $Report_path/$ID".report" -o $Report_path/$ID".species.bracken" -r 150 -l 'S'

$BrackenFold/./bracken -d $KRAKEN_DB -i $Report_path/$ID".report" -o $Report_path/$ID".genus.bracken" -r 150 -l 'G'
