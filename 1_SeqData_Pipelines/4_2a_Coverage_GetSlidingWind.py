import numpy as np
import sys
import csv
import pandas as pd


# In[2]:


## This script will run with coverage data for each chromosome separately.
## The files should have the form: 
### FileName + chrX + .txt

## call the script:

##    Coverage_GetInSlidingWindow #InPath #InFilename(without the endling and without the chr..) #OutPath #windowSize


# In[3]:


## what are the variables:
### -- inFile: is the path and filename of the file from which we want to cut the columns 
### -- windowSize: in what window should the coverage average be evaluated? (I am here not letting windows overlap,
###    because that would defeat the cause of making the file size smaller)
### -- out: path and name of the output sample


InPath = sys.argv[1]
InFilename = sys.argv[2]
outPath = sys.argv[3]
windowSize = int(sys.argv[4])

#InPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/1_Dev_PipelineCelegans/Coverage/fromMapping/"
#InFilename="Gent_bb_1_2_CE_mapped_compl_cov_"
#outPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/1_Dev_PipelineCelegans/Coverage/fromMapping/O_output/"
#windowSize = 10000
suffix = ".txt"

chromosomes=["NC_003279.8","NC_003280.10","NC_003281.10","NC_003282.8","NC_003283.11","NC_003284.9","NC_001328.1"]
chromosomes_length = [15072434, 15279421, 13783801, 17493829, 20924180, 17718942, 13794]
chromosomes_end = [15072434, 30351855, 44135656, 61629485, 82553665, 100272607, 100286401]
chr_shortNames = ["_chr1","_chr2","_chr3","_chr4","_chr5","_chr6","_chr7"]


# In[4]:

df_sldCov = pd.DataFrame({
    "ID":[],
    "chr":[],
    "pos":[],
    "pos_global":[],
    "cov_sldWinMean":[]})


for i in range(len(chr_shortNames)):
    
    df_pre=pd.read_csv(InPath + InFilename + chr_shortNames[i] + suffix,header=None, delimiter="\t", index_col=False, na_values="na")
    df_pre.columns=["chr",'pos','coverage']

    # test some things:
    if (df_pre.chr.values[0] == df_pre.chr.values[-1]) & (df_pre.chr.values[0] == chromosomes[i]) & (df_pre.chr.values[-1] == chromosomes_length[i]):
        print(df_pre.chr[0])
        continue

    # for each chromosome, get the positions at which to evaulate the coverage
    # always evaluate at the middle of the window 
    # example, windowSize=10000, evaluate at 5000 from 0 to 10000, at 15000 from 10001 to 20000 etc.
    loopNum = round(chromosomes_length[i]/windowSize)
    loopPos = np.round(np.arange(windowSize/2, (loopNum)*windowSize + windowSize/2, windowSize))
    posHere = df_pre.pos.values
    covHere = df_pre.coverage.values

    # get the global position by adding the ed point of the prior chromosome to the positions in the next chromosome
    if i == 0:
        globalPos = loopPos
    else:
        globalPos = loopPos + chromosomes_end[i-1]
        

    # initiate the data
    cov_sldWinMean = np.zeros(len(loopPos))

    # run the loop over all positions but not the last
    for j in range(len(loopPos)):
        if (loopPos[j] == loopPos[-1]) & (chromosomes_length[i] < (loopPos[j] + windowSize/2)):
            print(i)
            print(j)
            print("True")
            lastWinStart = int((loopPos[j]-windowSize/2))
            cov_sldWinMean[j] = np.nanmean(covHere[lastWinStart:posHere[-1]])
        else:    
            maskHere = (posHere > (loopPos[j] - windowSize/2)) & (posHere < (loopPos[j] + windowSize/2))
            cov_sldWinMean[j] = np.nanmean(covHere[maskHere])
    print(cov_sldWinMean)
    
    IDs = list(map(str.__add__, np.array(df_pre['chr'].values, dtype=str), np.array(np.array(loopPos, dtype = int), dtype=str)))
    df_here = pd.DataFrame({
        "ID": IDs,
        "chr": np.transpose(np.repeat(chromosomes[i],len(loopPos))),
        "pos": loopPos,
        "pos_global": np.array(globalPos, dtype=int),
        "cov_sldWinMean": cov_sldWinMean})

    df_sldCov = pd.concat([df_sldCov,df_here])
   


### save the data:
df_sldCov.to_pickle(outPath + "/" + InFilename + "_covSliWindow10000.pkl")
df_sldCov.to_csv(outPath + "/" + InFilename + "_covSliWindow10000.csv", index=False)

