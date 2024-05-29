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


inName = "KraBracken_DBstandard_042024_0minFrac_genus_FromPY.csv"
inPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/2_Metagenomics/1_taxonomy/"

################ LOAD DATA #######################
dataIn <- read.csv(paste(inPath, inName, sep = ""),sep = ",", header = TRUE)
dataDim <- dim(dataIn)


SpecAbund <- dataIn[1:dataDim[1],6:dataDim[2]]
SpecAbund_mat <- as.matrix(SpecAbund)
SampleInfo <- dataIn[,1:5]
SampleInfo$week <- as.character(SampleInfo$week)
Spec <- dataIn[1,6:dataDim[2]]

dataframe <- dataIn[,c(-1,-2,-3,-4,-5)]


dist <- vegan::vegdist(dataframe,  method = "bray")
bray_curtis_pcoa <- ecodist::pco(dist)

# All components could be found here: 
# bray_curtis_pcoa$vectors
# But we only need the first two to demonstrate what we can do:
bray_curtis_pcoa_df <- data.frame(pcoa1 = bray_curtis_pcoa$vectors[,1], 
                                  pcoa2 = bray_curtis_pcoa$vectors[,2])

# Create a plot
bray_curtis_plot <- ggplot(data = bray_curtis_pcoa_df, aes(x=pcoa1, y=pcoa2, colour=SampleInfo$treatment, shape=SampleInfo$institution)) +
  geom_point() +
  labs(x = "PC1",
       y = "PC2", 
       title = "Bray-Curtis PCoA") +
  theme(title = element_text(size = 10)) # makes titles smaller

bray_curtis_plot



### other package
#PCOA <- pcoa(dist)


# plot the eigenvalues and interpret
#barplot(PCOA$values$Relative_eig[1:10])
# Can you also calculate the cumulative explained variance of the first 3 axes?

# Some distance measures may result in negative eigenvalues. In that case, add a correction:
#PCOA <- pcoa(dist)

# Plot your results
#biplot.pcoa(PCOA)
