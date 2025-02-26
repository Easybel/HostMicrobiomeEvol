import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import glob

# read in data to panda
# get the number of unclassified reads from Kraken2 outputs

InPath="/zfs/omics/projects/cevolution/CE_mapped/coverage/"
files=glob.glob(InPath+"*compl_cov.txt")
print(files)
outPath="/zfs/omics/projects/cevolution/CE_mapped/coverage/out/"
chromosomes=["NC_003279.8","NC_003280.10","NC_003281.10","NC_003282.8","NC_003283.11","NC_003284.9","NC_001328.1"]


samName_collect = []
means = np.zeros(len(files))
standdev = np.zeros(len(files))

fig1, ax1 = plt.subplots(figsize=(14,10))
fig2, ax2 = plt.subplots(figsize=(14,10))
fig3, ax3 = plt.subplots(figsize=(14,10))
fig4, ax4 = plt.subplots(figsize=(14,10))
fig5, ax5 = plt.subplots(figsize=(14,10))
fig6, ax6 = plt.subplots(figsize=(14,10))
fig7, ax7 = plt.subplots(figsize=(14,10))

figs = [fig1, fig2, fig3, fig4, fig5, fig6, fig7]
axs = [ax1, ax2, ax3, ax4, ax5, ax6, ax7]


for i in range(len(files)):
    df_pre = []
    
    a = files[i].split('/')
    sample=a[-1].split('_')

    sampleName="_".join(sample[0:4])
    samName_collect.append(sampleName)

    df_pre=pd.read_csv(files[i],header=None, delimiter="\t", index_col=False, na_values="na")
    df_pre.columns=["chr","pos","cov"]

    means[i] = np.mean(df_pre.iloc[:,2].values)
    standdev[i] = np.std(df_pre.iloc[:,2].values)


    # plot per chromosome
    for j in range(len(chromosomes)):
        df_chrHere = []
        df_chrHere = df_pre[df_pre['chr']==chromosomes[j]]
        
        axs[j].plot(df_chrHere.iloc[:,1].values, df_chrHere.iloc[:,2].values, label=sampleName)

for c in range(len(chromosomes)):
    axs[c].set_title(chromosomes[c])
    axs[c].set_xlabel("coverage")
    axs[c].set_ylabel("frequency")
    figs[c].savefig(outPath + "Coverage_plot_chr" + str(c+1) + "_" + chromosomes[c] + ".jpg", dpi=200)
    axs[c].legend()

## write it and save it!
df_collect=pd.DataFrame({
    "sample": samName_collect,
    "mean":means,
    "stddeviation":standdev
})


df_collect.to_pickle(outPath + "Coverage_collect.pkl")

