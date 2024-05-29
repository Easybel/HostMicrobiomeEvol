def GetPiOverview(sampleNames, df_shiftRaw, df_shiftNorm, collect_NanNum):
    
    import numpy as np
    import pandas as pd
    ## prepare data to get the 
    samName_collect_pi = ["pi_"+s for s in sampleNames]
    samName_collect_piNorm = ["piNorm_"+s for s in sampleNames]
    
    # get part of the 
    df_pi = df_shiftRaw[samName_collect_pi]
    df_piNorm = df_shiftNorm[samName_collect_piNorm]
    
    
    ## get stuff for plotting
    rowNames = df_pi.mean(0).index.tolist()
    
    institution = []
    treatment = []
    inst_treat =  []
    week = []
    rep = []
    newRowName = []
    
    for i in rowNames:
        nameList = i.split('_')
        institution.append(nameList[1])
        treatment.append(nameList[2])
        inst_treat.append(nameList[1] + "_" + nameList[2])
        week.append(int(nameList[3]))
        rep.append(nameList[4])
    
        newRowName.append(nameList[1] + "_" + nameList[2] + "_" + nameList[3] + "_" + nameList[4])
    
        ## create the panda data frame
    overview = pd.DataFrame(
        {'ID': newRowName,
        'institution': institution,
        'treatment': treatment,
        'inst_treat': inst_treat,
        'week': week,
        'rep': rep,
        'pi_mean': df_pi.mean(0),
        'pi_std': df_pi.std(0),
        'piNorm_mean': df_piNorm.mean(0).values,
        'piNorm_std': df_piNorm.std(0).values,
        'piNormwNaN_mean': df_piNorm.mean(0).values * (1- collect_NanNum/df_shiftRaw.shape[0]),
        'piNormwNaN_std': df_piNorm.std(0).values * (1 - collect_NanNum/df_shiftRaw.shape[0])}
    )
    
    overview.set_index(['institution','treatment','inst_treat','week','rep'])
    overview.sort_index()

    return overview