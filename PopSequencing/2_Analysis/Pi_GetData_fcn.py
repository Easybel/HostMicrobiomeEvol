def GetData(files, chrs, chrs_end, subsample):

## an option that I want to biuld in:
    # set all windows with less than minCov % covered with usable data to a pi of na
    # maybe output this then as df_shiftRaw_cut or something 

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
        df_pre.columns=["chr",'window','SNPnum','freq' + "_" + sampleName ,"pi" + "_" + sampleName]
        
        # get the IDs that will be chr name + position
        IDs = list(map(str.__add__, np.array(df_pre['chr'].values, dtype=str), np.array(df_pre['window'].values, dtype=str)))
        df_pre.insert(0, "ID", IDs, True)

        df_pre.set_index("ID",inplace=True)

        ### modify df_pre -- such that it can be plotted in one picture
        ### this only has to be done for the first sample, as the others have unique ID
    
        if i==0: # for the first sample we have to shift the positions
            # start with the first chromosome that doesnt have to be shifted!
            df_shiftRaw = df_pre[df_pre['chr']==chrs[0]]
            for j in range(1, len(chrs)):
                df_here = df_pre[df_pre['chr']==chrs[j]]
                addValue = chrs_end[j-1]
                df_here['window'] = df_here['window'].add(addValue)
       
                df_shiftRaw = pd.concat([df_shiftRaw,df_here])
        
        else: # for all other samples we just use the ID that is a unique name including the chromosome ID and position
            df_shiftRaw = pd.merge(df_shiftRaw, df_pre[['freq' + "_" + sampleName , "pi" + "_" + sampleName]], on="ID", how="outer")


    df_shiftRaw = df_shiftRaw.sort_values(['window'])
    df_shiftRaw = df_shiftRaw.drop(columns="SNPnum")

    ## now get the df where the pi and freq are multiplied per window
    df_shiftNorm = df_shiftRaw[["chr","window"]]
    collect_NanNum = np.zeros(len(samName_collect))

    ## loop over all sample names and add the columns that have the normalized pi value
    for i in range(len(samName_collect)):    
        nameHere = samName_collect[i]
        normPi = np.array(df_shiftRaw["freq_" + nameHere].values)*np.array(df_shiftRaw["pi_" + nameHere].values)
        df_shiftNorm["piNorm_" + nameHere] = normPi
        df_shiftNorm

        collect_NanNum[i] = sum(np.isnan(normPi))

    return samName_collect, df_shiftRaw, df_shiftNorm, collect_NanNum