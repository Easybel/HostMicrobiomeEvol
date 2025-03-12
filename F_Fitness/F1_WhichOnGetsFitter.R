## In this script, we get the increase of fitness
##   between w1 and w15 for growth rate:
#

library(ggplot2)
library(readxl)


## Get data:
#load the data
data.In = read_excel("/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/2_Analysis/dataset_total_Mar21_editIR.xlsx", sheet = 1)
outPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/2_Analysis/output/"
outName = "Fitness101024"

# only keep interesting columns 
df <- data.In[ c("label","serie","line","lab","week","replicate","treat","growth_nematode_m") ]

# what data should we kick out? 
##### the measurements of week 14 and 16 we can't use
##### lab="LEI" we wont use
df_all <- df[df$week=="0" | df$week=="1" | df$week=="15",]
df_all <- df_all[df_all$lab!="LEI",]

## kick out negative fitness values:
df_all <- df_all[df_all$growth_nematode_m >= 0,]

##########################################################
##########################################################
#### First, do the easy analysis:
## ----- average over all technical replicates per sample:

df_all_Simple <- data.frame(labelUniq=unique(df_all$label), ID = NA, inst_treat = NA,
                            sampleIdx = NA, institution = NA, treatment = NA, 
                            replicate = NA, week = NA, sampleMean = NA, sampleStd = NA) 

# loop over the dataframe and get the mean for each label across the different measurements
for (i in 1:dim(df_all_Simple)[1]) {
  sampleHere <- df_all_Simple$labelUniq[i]
  
  # split up the name and get the ID
  splitted<- unlist(strsplit(df_all_Simple$labelUniq[i], "\\."))
  inst_treat <- unlist(strsplit(splitted[1], "_"))
  
  sampleIdx <- which(df_all$label==df_all_Simple$labelUniq[i])
  sampleInst <- df_all$lab[sampleIdx[1]]
  sampleTreat <- df_all$treat[sampleIdx[1]]
  sampleRep <- df_all$replicate[sampleIdx[1]]
  sampleWeek <- df_all$week[sampleIdx[1]]
  sampleMean <- mean(df_all$growth_nematode_m[sampleIdx])
  sampleStd <- sd(df_all$growth_nematode_m[sampleIdx])
  
  # now write the data to the data frame .._Simple
  df_all_Simple$inst_treat[i] <- paste(df_all$lab[sampleIdx[1]],df_all$treat[sampleIdx[1]],sep = "_")
  df_all_Simple$ID[i] <- paste(df_all$lab[sampleIdx[1]],df_all$treat[sampleIdx[1]],sampleRep,sep = "_")
  df_all_Simple$sampleIdx[i] <- list(sampleIdx)
  
  df_all_Simple$institution[i] <- sampleInst
  df_all_Simple$treatment[i] <- sampleTreat
  
  df_all_Simple$replicate[i] <- sampleRep
  df_all_Simple$week[i] <- sampleWeek
  df_all_Simple$sampleMean[i] <- sampleMean
  df_all_Simple$sampleStd[i] <- sampleStd
  
} 
plot1 <- ggplot(data = df_all[(df_all$week==1 | df_all$week==0),], aes(x = line, y = growth_nematode_m))+ #, fill = treatment)) +
  geom_boxplot(alpha = 1)+
  geom_jitter(aes(color = lab),alpha=1) +
  theme_bw() + 
  xlab("") + 
  ylab("nematode growth rate")+
  theme(axis.text.x = element_text(angle = 90))
plot1

plot2 <- ggplot(data = df_all[(df_all$week==15),], aes(x = line, y = growth_nematode_m))+ #, fill = treatment)) +
  geom_boxplot(alpha = 1)+
  geom_jitter(aes(color = lab),alpha=1) +
  theme_bw() + 
  xlab("") + 
  ylab("nematode growth rate")+
  theme(axis.text.x = element_text(angle = 90))
plot2

##### Plot the easy data:
## make boxplots for institutions and time points 
ggplot(df_all_Simple, aes(inst_treat, sampleMean, fill=factor(week))) +
  geom_boxplot()

ggplot(df_all[df_all$lab=="Gent",], aes(line, growth_nematode_m, fill=factor(label))) +
  geom_boxplot()



##########################################################
########################################################## week 0 or 1 VS week 15
#### Second, do the more advanced stuff:
## ----- get the pairs of week 1 and week 15 data and collect the different replicates
## ----- then get the slope for all possible pairs and get the mean of that slope and the standard error

## collect the matching weeks
df_Pairs_w0_1to15 <- data.frame(ID = df_all_Simple$ID[df_all_Simple$week==1 | df_all_Simple$week==0],
                                inst_treat = df_all_Simple$inst_treat[df_all_Simple$week==1 | df_all_Simple$week==0],
                           institution =  df_all_Simple$institution[df_all_Simple$week==1 | df_all_Simple$week==0],
                           treatment = df_all_Simple$treatment[df_all_Simple$week==1 | df_all_Simple$week==0], 
                           replicate = df_all_Simple$replicate[df_all_Simple$week==1 | df_all_Simple$week==0],
                           week_start = df_all_Simple$week[df_all_Simple$week==1 | df_all_Simple$week==0],
                           week_end = NA,
                                 SampleIdx_start = NA, SampleIdx_end = NA, simpleMean_start = NA, simpleMean_end = NA, simpleSlope = NA,
                                 collectMean = NA, stderr = NA,
                                 collectSlope = NA, fitness_start = NA, fitness_end = NA)
                            

for (i in 1:dim(df_Pairs_w0_1to15)[1]) {
  IDHere <- df_Pairs_w0_1to15$ID[i]
  repHere<- df_Pairs_w0_1to15$replicate[i] 
  weekHere <- df_Pairs_w0_1to15$week_start[i] 
  
  # collect the data across samples
  sampleIdx_start <- unlist(df_all_Simple$sampleIdx[df_all_Simple$week== weekHere & df_all_Simple$ID==IDHere & df_all_Simple$replicate==repHere])
  sampleIdx_end <- unlist(df_all_Simple$sampleIdx[df_all_Simple$week==15 & df_all_Simple$ID==IDHere & df_all_Simple$replicate==repHere])
  
  if (is.null(sampleIdx_end)) {
    next
  }
  
  week_start <- df_all$week[sampleIdx_start[1]] 
  week_end   <- df_all$week[sampleIdx_end[1]] 
  df_Pairs_w0_1to15$week_end[i] <- week_end
  
  # collect the data 
  fitness_1 <- df_all$growth_nematode_m[array(unlist(sampleIdx_start))]
  fitness_2 <- df_all$growth_nematode_m[array(unlist(sampleIdx_end))]
  
  simpleMean_1 <- mean(fitness_1)
  simpleMean_2 <- mean(fitness_2)
  simpleSlope <- (simpleMean_2 - simpleMean_1)
  
  ## write the data to the data frame
  df_Pairs_w0_1to15$SampleIdx_start[i] <- list(sampleIdx_start)
  df_Pairs_w0_1to15$SampleIdx_end[i] <- list(sampleIdx_end)
  df_Pairs_w0_1to15$simpleMean_start[i] <- simpleMean_1
  df_Pairs_w0_1to15$simpleMean_end[i] <- simpleMean_2
  df_Pairs_w0_1to15$simpleSlope[i] <- simpleSlope
  df_Pairs_w0_1to15$fitness_start[i] <- list(fitness_1)
  df_Pairs_w0_1to15$fitness_end[i] <- list(fitness_2)
  
  ## get the mean and std of the slope of all of the pairs of start and end fitness 
  startNum <- length((sampleIdx_start)) # --->>>> loop with idx s will run over this
  endNum   <- length((sampleIdx_end))   # --->>>> loop with idx x will run over this
  # and now loop over 
  collectSlope <- NULL
  
  for (s in 1:startNum) {
    for (x in 1:endNum) {
      sslope <- (fitness_2[x] - fitness_1[s])
      collectSlope <- rbind(collectSlope, sslope)
    }
  }
  df_Pairs_w0_1to15$collectSlope[i] <- list(collectSlope)
  df_Pairs_w0_1to15$collectMean[i] <- mean(collectSlope)
  df_Pairs_w0_1to15$stderr[i] <- sd(collectSlope)/sqrt(length(collectSlope))
}


## get rid of the rows where there is no week 15 data for
df_Pairs_w0_1to15 <- df_Pairs_w0_1to15[complete.cases(df_Pairs_w0_1to15[ , 7]), ]



## save the data
#save(df_all_Simple,  file = paste(outPath,outName,"_df_all_Simple_woNegFitness.RData", sep = ""))
#save(df_Pairs_w0_1to15,  file = paste(outPath,outName,"_df_Pairs_w1to15_woNegFitness.RData", sep = ""))



