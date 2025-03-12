#!/bin/bash
#SBATCH --job-name=kraken_test
#SBATCH --mail-type=ALL 
#SBATCH --mail-user 14831627@omics-h0.science.uva.nl
#SBATCH --cpus-per-task=8
#SBATCH --mem=100G
#SBATCH --nodes=1
#SBATCH --time=10:00:00 

# Set the path to the Kraken2 executable
KRAKEN2_PATH=/zfs/omics/projects/cevolution/software/kraken2/./kraken2

# Set the path to the Kraken2 database
KRAKEN2_DB=/zfs/omics/projects/cevolution/NCBI_Database

# Set the output directory for taxonomic classification results
OUTPUT_DIR=/zfs/omics/projects/cevolution/TestData_Meta/KrakenResults

echo "loop starting"

# Loop through each file
for file in /zfs/omics/projects/cevolution/TestData_Meta/*.fastq.gz; do
	echo "path works"
	#Extract base files name without extension 
	base=$(basename "$file" .fastq.gz)
	echo "base files extracted"
	#Run kraken2 for classification 
	$KRAKEN2_PATH --db "$KRAKEN2_DB" --gzip-compressed "$file" --output "$OUTPUT_DIR/$base.kraken2.out" --report "$OUTPUT_DIR/$base.kraken2.report"
done

echo "Taxonomic classification completed. Results saved in $OUTPUT_FILE"
