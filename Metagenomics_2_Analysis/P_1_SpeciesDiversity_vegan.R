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


inName = "KraBracken_DBplusPf_062024_0.01minFrac_genus_FromPY.csv"
inPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/2_Metagenomics/1_taxonomy/3_FinalAbunData/"
outPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/2_Metagenomics/1_taxonomy/out/"
outName = "KraBracken_DBstandard_082024_0.01minFrac_genus_Shannon_FromR.csv"
################ LOAD DATA #######################
dataIn <- read.csv(paste(inPath, inName, sep = ""),sep = ",", header = TRUE)
dataDim <- dim(dataIn)


SpecAbund <- dataIn[1:dataDim[1],6:dataDim[2]]
spec <- as.matrix(SpecAbund)
SampleInfo <- dataIn[,1:5]
SampleInfo$week <- as.character(SampleInfo$week)
Spec <- dataIn[1,6:dataDim[2]]

dataframe <- dataIn[,c(-1,-2,-3,-4,-5)]

## from Numverical Ecology in R (Daniel Borcard François Gillet, Pierre Legendre, 2011)
N0 <- rowSums(spec > 0)   # Species richness
H <- diversity(spec)      # Shannon entropy
N1 <- exp(H)              # Shannon diversity number
N2 <- diversity(spec, "inv") # Simpson diversity number
J <- H/log(N0)            # Pielou eveness
E1 <- N1/N0               # Shannon evenness (Hill's ratio)
E2 <- N2/N0              # Simpson evenness (Hill's ratio)
div <- data.frame(N0, H, N1, N2, E1, E2, J)

hist(H,  ylim = c(0, 30), breaks=10)

## plot boxplots to visualize hox the treatment and time point influence the diversity
# create a data frame
microbiome=data.frame(SampleInfo, H)

# grouped boxplot
ggplot(microbiome, aes(x=institution, y=H, fill=treatment)) + 
  geom_boxplot()




write.csv(microbiome, paste(outPath,outName, sep = ""), row.names = FALSE)

