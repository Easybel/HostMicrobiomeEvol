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

par (mfrow = c(1,2))
pcoa <- capscale(log1p(SpecAbund_mat) ~ 1, distance = 'bray', sqrt.dist = TRUE, scaling = 1)
plot(pcoa, main = 'PCoA (MDS)', type = 'n', xlim=c(-2,2))
points (pcoa, display = 'si', col = SampleInfo$week, pch = SampleInfo$week)
text(pcoa, display = 'sp', col = "#FF000080", cex = 0.6, scaling = 1, select = colSums(SpecAbund_mat>0)>20)
legend ('bottomleft', pch = 1:4, col = 1:4, legend = 1:4, title = 'GROUP', cex = 0.6)

ylim=c(0,20)
### other package
#PCOA <- pcoa(dist)


# plot the eigenvalues and interpret
#barplot(PCOA$values$Relative_eig[1:10])
# Can you also calculate the cumulative explained variance of the first 3 axes?

# Some distance measures may result in negative eigenvalues. In that case, add a correction:
#PCOA <- pcoa(dist)

# Plot your results
#biplot.pcoa(PCOA)
