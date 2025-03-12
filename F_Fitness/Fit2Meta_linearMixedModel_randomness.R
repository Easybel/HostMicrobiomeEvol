## Here we want to get the betadiversity measure (Bray-Curtis distance )
### and then get the PCoA of that 

### install packages and load them
library(pheatmap)
library(ggplot2)
library(vegan)
library(labdsv)
library(readxl)
library(ggsci)
library(ggforce)
library(ggrepel) 
library(BiodiversityR)
library(ape)

inFit = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/2_Analysis/df_notexpand_FitnessPairs_w1to15_woNegFitness.RData"

inMeta = "KraBracken_DBstandard_042024_0minFrac_genus_FromPY.csv"
inMetaPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/2_Metagenomics/1_taxonomy/"

outPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/2_Analysis/"

################ LOAD DATA #######################
dataIn <- read.csv(paste(inMetaPath, inMeta, sep = ""),sep = ",", header = TRUE)
dataDim <- dim(dataIn)

a = load(inFit)
df_Pairs_w0_1to15 <- get(a)
rm(a)

SpecAbund <- dataIn[1:dataDim[1],6:dataDim[2]]
SpecAbund_mat <- as.matrix(SpecAbund)
SampleInfo <- dataIn[,1:5]
SampleInfo$week <- as.character(SampleInfo$week)
Spec <- dataIn[1,6:dataDim[2]]

dataframe <- dataIn[,c(-1,-2,-3,-4,-5)]

## get the bray curtis distances
dist <- vegan::vegdist(dataframe,  method = "bray")
dist_mat <- as.matrix(dist)

image(dist_mat)
##### combine the data

# add an empty column
df_wMeta <- cbind(df_Pairs_w0_1to15, betadiver=NA)
for (i in 1:dim(df_Pairs_w0_1to15)[1]) {
  nameStart <- paste(df_wMeta$inst_treat[i],df_wMeta$week_start[i],df_wMeta$replicate[i], sep = "_")
  nameEnd <- paste(df_wMeta$inst_treat[i],df_wMeta$week_end[i],df_wMeta$replicate[i], sep = "_")
  
  #get Beta 
  MaskStart <- SampleInfo$name_short == nameStart
  MaskEnd <- SampleInfo$name_short == nameEnd
  
  if (any(MaskStart) & any(MaskEnd)) { 
  df_wMeta$betadiver[i] <- dist_mat[which(MaskStart),which(MaskEnd)] 
  }
  else {
    next
  }
}


plot2 <- ggplot(data = df_expand, aes(x = ID, y = slope))+ #, fill = treatment)) +
  geom_boxplot(alpha = 1)+
  geom_jitter(aes(color = ID),alpha=1) +
  theme_bw() + 
  xlab("") + 
  ylab("fitness difference (week 0 or 1 and week 15)")+
  theme(axis.text.x = element_text(angle = 90))
plot2

###### save the output
df_wMeta_notexpand <- df_wMeta
save(df_wMeta_notexpand,  file = paste(outPath,"df_wMeta_notexpand_FitnessPairs_w1to15_woNegFitness.RData", sep = ""))

