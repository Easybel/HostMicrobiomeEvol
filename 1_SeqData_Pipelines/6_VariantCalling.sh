










## In this script, we want to call the variants in the poolSeq data
## -- input:  bam file
## -- output:

### First, we go the popoolation way over mpileup and sync
## 1. Create mpileup from bam  
bcftools mpileup -e 10 -F 0.00001 -h 80 -L 10000 -o 20 -a FORMAT/AD -d 8000 -f $myDictPath/$dict.fasta $myDataPath/$IDout"_sort.bam" > $myDataPath/$IDout"_bcf.vcf"
bcftools call -vc $myDataPath/$IDout"_bcf.vcf" > $myDataPath/$IDout"_bcfcall.vcf"
## 2. create the sync file


### Second, maybe use a different tool to call variants (CRISP, freeBAYES, ..CRISP, freeBAYES, ....)
