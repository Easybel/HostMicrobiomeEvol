## In this script, we get the increase of fitness
##   between w1 and w15 for growth rate:
#

library(ggplot2)
library(readxl)
library(hrbrthemes)


## Get data:
#load the data
### for the fitness assessement
load("/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/2_Analysis/Fitness_Slope_wError_df_all_Simple.RData")
load("/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/2_Analysis/Fitness_Slope_wError_df_all_Pairs.RData")

### for the microbiome!
microbiome.In = read.csv("/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/2_Metagenomics/1_taxonomy/KraBracken_DBstandard_042024_0minFrac_genus_Shannon_FromR.csv")

### now there are different angles:
# 1. 

## -- take all the samples from w0, w1 and w15 and correlate the growth rate 
##    with their alpha diversity 

## take the fitness data frame and 
merge_FitMicrobe <- merge(x = df_all_Simple, y = microbiome.In, by = c("institution","treatment","replicate","week"), all.x = TRUE)
merge_FitSlopeMicrobeW15 <- merge(x = df_all_Pairs, y = microbiome.In[microbiome.In$week==15,], by = c("institution","treatment","replicate"), all.x = TRUE)

merge_FitMicrobe_w15 <- merge_FitMicrobe[merge_FitMicrobe$week==15,]

ggplot(merge_FitMicrobe_w15, aes(x=sampleMean, y=alpha, color=treatment, shape=institution)) + 
  geom_point() +
  theme_ipsum()

#shape=Species, alpha=Species, size=Species, color=Species

## but also interesting is to see if the slope correlates with the diversity at week 15
ggplot(merge_FitSlopeMicrobeW15, aes(x=collectMean, y=alpha, color=institution, shape=treatment)) + 
  geom_point() +
  theme_ipsum()

