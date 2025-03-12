import numpy as np
import sys
import csv
import pandas as pd
import matplotlib.pyplot as plt
import glob

## This script will run with coverage data for each chromosome separately.
## The files should have the form: 
### FileName + chrX + .txt

## Purpose: Plot histogram of coverage from all single positions
## call the script:
## 3e_C_Coverage_Plot_RawDataHistogram.py #InPath #InFilePattern #outPlots #suffix

## what are the variables:
### -- inPath and inFilePattern: is the path and pattern with which to find a list of file names. These samples will be plotted together then and for each separate sample also the different chromosomes will be plotted together 
###    because that would defeat the cause of making the file size smaller)
### -- outPlots: path tp where to put plots
### -- suffix: anything that is in the sample name except for sample ID and .txt

InPath = sys.argv[1]
InFilePattern = sys.argv[2]
outPlots = sys.argv[3]
suffix = sys.argv[4]

#InPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/1_Dev_PipelineCelegans/Coverage/fromMapping/"
#InFilePattern = "Gent_bb"
#outPlots = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/1_Dev_PipelineCelegans/Coverage/fromMapping/O_plots/"
#suffix = "_CE_mapped_compl_cov_"

InFileList = glob.glob(InPath+InFilePattern+"*.txt")

chromosomes=["NC_003279.8","NC_003280.10","NC_003281.10","NC_003282.8","NC_003283.11","NC_003284.9","NC_001328.1"]
chromosomes_length = [15072434, 15279421, 13783801, 17493829, 20924180, 17718942, 13794]
chromosomes_end = [15072434, 30351855, 44135656, 61629485, 82553665, 100272607, 100286401]
chr_shortNames = ["chr1","chr2","chr3","chr4","chr5","chr6","chr7"]
chr_color = ["black","red","blue","purple","green","grey","orange"]

sys.stdout = open('py_testfile.txt', 'w')
print(InPath+InFilePattern+"*.txt")

## how many unique samples are there that I want to go through chromosome by chromosome?
## collect sample names
sampleNames = []
for s in range(len(InFileList)):

    name_here = InFileList[s].split("/")[-1]
    name_split = name_here.split("_")
    new_name = "_".join(name_split[0:4])
    sampleNames.append(new_name)

sampleNamesArray = np.array(sampleNames)
sampleNames_uniq = np.unique(sampleNamesArray)

## loop over samples and create plots/ save them alongside
    
## create 1 figure that collects the genome-wide coverage for all samples
fig1, axs1 = plt.subplots(1,1, figsize=[12,6])

for s in range(len(sampleNames_uniq)):

    ## for each sample, initiate a fig1b that collects chromosomes 
    fig1b, axs1b = plt.subplots(1,1, figsize=[12,6])

    sampleHere = sampleNames_uniq[s]


    df_collect = pd.DataFrame({
        "chr":[],
        "pos":[],
        "coverage":[]})
   

    for i in range(len(chr_shortNames)): ## loop over chromosomes

        df_pre=pd.read_csv(InPath + sampleHere + suffix + chr_shortNames[i] + ".txt",header=None, delimiter="\t", index_col=False, na_values="na")
        df_pre.columns=["chr",'pos','coverage']

        # test some things:
        if (df_pre.chr.values[0] == df_pre.chr.values[-1]) & (df_pre.chr.values[0] == chromosomes[i]) & (df_pre.chr.values[-1] == chromosomes_length[i]):
            print(df_pre.chr[0])
            continue

        ## plot the single chromosomes
        bins = np.linspace(0,500,100)
        axs1b.hist(df_pre.coverage.values, bins = bins, alpha = 0.2, color=chr_color[i], edgecolor=chr_color[i],  linewidth=1.2)
        axs1b.set_xlim([0,450])
        axs1b.set_title(sampleHere)

        df_collect = pd.concat([df_collect,df_pre])

        
    ## save the sample-wise figure
    axs1b.legend(chromosomes, loc="upper right")
    fig1b.savefig(outPlots + sampleHere + "_overview_allChr.png",
             dpi=300, bbox_inches='tight')


    num_pos = len(df_collect.coverage.values)

    sys.stdout = open('py_testfile.txt', 'a')
    print(sampleHere)
    sys.stdout.close()

    bins = np.linspace(0,500,100)
    axs1.hist(df_collect.coverage.values, bins = bins, alpha = 0.3, edgecolor="black", linewidth=1.2)
    
    ## lower 1% of the dist
    first1Perc = int(np.round(num_pos/100))
    
    ## upper 1% of the dist
    last1Perc = int(np.round(99*num_pos/100))
    
    sorted_cov = np.sort(df_collect.coverage.values)
    Tails = np.array([sorted_cov[first1Perc], sorted_cov[last1Perc]])
    
    axs1.text(320, 1.5e6 + s*0.9e6, sampleHere + str(Tails))
    
## save the overall figure
axs1.legend(sampleNames_uniq)
axs1.set_xlim([0,450])
axs1.set_title("Overview of samples")
fig1.savefig(outPlots + InFilePattern + "_overview.png", 
             dpi=300, bbox_inches='tight')



