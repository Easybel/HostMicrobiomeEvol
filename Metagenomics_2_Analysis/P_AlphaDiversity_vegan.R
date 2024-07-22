## Here we want to get the alpha diversity with vegan

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


inName = "KraBracken_DBstandard_042024_0minFrac_genus_FromPY.csv"
inPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/2_Metagenomics/1_taxonomy/"
outPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/2_Metagenomics/1_taxonomy/"
outName = "KraBracken_DBstandard_042024_0minFrac_genus_Shannon_FromR.csv"
################ LOAD DATA #######################
dataIn <- read.csv(paste(inPath, inName, sep = ""),sep = ",", header = TRUE)
dataDim <- dim(dataIn)


SpecAbund <- dataIn[1:dataDim[1],6:dataDim[2]]
SpecAbund_mat <- as.matrix(SpecAbund)
SampleInfo <- dataIn[,1:5]
SampleInfo$week <- as.character(SampleInfo$week)
Spec <- dataIn[1,6:dataDim[2]]

dataframe <- dataIn[,c(-1,-2,-3,-4,-5)]

alpha <- diversity(SpecAbund, index = "shannon")
hist(alpha,  ylim = c(0, 30), breaks=10)

## plot boxplots to visualize hox the treatment and time point influence the diversity
# create a data frame
microbiome=data.frame(SampleInfo, alpha)

# grouped boxplot
ggplot(microbiome, aes(x=institution, y=alpha, fill=treatment)) + 
  geom_boxplot()


write.csv(microbiome, paste(outPath,outName, sep = ""), row.names = FALSE)

