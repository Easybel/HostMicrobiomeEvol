# CnemEvol_Microbes
In this repository, we document the scripts needed to analyse the metagenomic data gathered in a evolution experiment performed on C. elegans. 


First, we ..... (general pipeline)

To perform taxonomic classification, we used kraken2 (cite) with the DB PlusPF: Standard plus Refeq protozoa & fungi (https://benlangmead.github.io/aws-indexes/k2, downloaded May 2024). On the outputs we ran bracken (cite) to obtain relative abundacies of taxa (on the genus level).
