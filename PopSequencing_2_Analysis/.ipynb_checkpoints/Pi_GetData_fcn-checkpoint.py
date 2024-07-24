def GetData(files, chrs, chrs_end, subsample):


#in that function it:
#  1. shifts the window position so that it applies to the whole genome and not chromosome position (but it keeps the old position in case you want to look at chromosomes separately)
#  2. all samples are joined in the data frame df_shiftRaw with the raw data for fraction (%) of window covered and diversity (e.g. pi diversity) per window
#  3. there is also df_shiftNorm with the window div multiplied with the frac    

###

# variables, examples:
# files: list of file names with paths
# chrs = ["NC_003279.8","NC_003280.10","NC_003281.10","NC_003282.8","NC_003283.11","NC_003284.9","NC_001328.1"]
# chrs_end = [1.50750e+07, 3.03500e+07, 4.41350e+07, 6.16300e+07, 8.25550e+07, 1.00270e+08, 1.00285e+08]
# subsample= False or True; False= Single data, 1 file for each sample; True= subsampling and multiple files per biological sample have to be taken care of 

##### CODE ##########################################################################################################
    
    import numpy as np
    import pandas as pd

    samName_collect = []

    for i in range(len(files)):
        df_pre = []
        a = files[i].split('/')
        sample=a[-1].split('_')

        if subsample==True:
            aa=sample[0:4]
            aa.append(sample[5])
            sampleName = "_".join(aa)
        else:
            sampleName="_".join(sample[0:4])

        samName_collect.append(sampleName)

        df_pre=pd.read_csv(files[i],header=None, delimiter="\t", index_col=False, na_values="na")
        df_pre.columns=["chr",'window','SNPnum','frac' + "_" + sampleName ,"div" + "_" + sampleName]
        
        # get the IDs that will be chr name + position
        IDs = list(map(str.__add__, np.array(df_pre['chr'].values, dtype=str), np.array(df_pre['window'].values, dtype=str)))
        df_pre.insert(0, "ID", IDs, True)
        df_pre.insert(2, "window_old", df_pre['window'].values,True)
        df_pre.set_index("ID",inplace=True)

        ### 1. shifts the window position so that it applies to the whole genome and not chromosome position
        ###    -- this only has to be done for the first sample, as the others have unique ID and can be joined with the first
    
        if i==0: # for the first sample we have to shift the positions
            # start with the first chromosome that doesnt have to be shifted!
            df_shiftRaw = df_pre[df_pre['chr']==chrs[0]]
            for j in range(1, len(chrs)):
                df_here = df_pre[df_pre['chr']==chrs[j]]
                addValue = chrs_end[j-1]
                df_here['window'] = df_here['window'].add(addValue)
       
                df_shiftRaw = pd.concat([df_shiftRaw,df_here])
        ### 2. all samples are joined in the data frame df_shiftRaw with the raw data for fraction (%) of window covered 
        ###    and diversity (e.g. pi diversity) per window
        else: # for all other samples we just use the ID that is a unique name including the chromosome ID and position
            df_shiftRaw = pd.merge(df_shiftRaw, df_pre[['frac' + "_" + sampleName , "div" + "_" + sampleName]], on="ID", how="outer")


    df_shiftRaw = df_shiftRaw.sort_values(['window'])
    df_shiftRaw = df_shiftRaw.drop(columns="SNPnum")


    ### 3. there is also df_shiftNorm with the window div multiplied with the frac    
    df_shiftNorm = df_shiftRaw[["chr","window_old","window"]]
    collect_NanNum = np.zeros(len(samName_collect))
    collect_sumofWeights = np.zeros(len(samName_collect))
    
    ## loop over all sample names and add the columns that have the normalized div value (div_i * frac_i for each window)
    for i in range(len(samName_collect)):    
        nameHere = samName_collect[i]
        normDiv = np.array(df_shiftRaw["frac_" + nameHere].values)*np.array(df_shiftRaw["div_" + nameHere].values)
        df_shiftNorm["divNorm_" + nameHere] = normDiv

        collect_NanNum[i] = np.sum(np.isnan(normDiv))
        collect_sumofWeights[i] = np.sum(np.array(df_shiftRaw["frac_" + nameHere].values))

    return samName_collect, df_shiftRaw, df_shiftNorm, collect_sumofWeights, collect_NanNum