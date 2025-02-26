## Script that reads the abundacy data
setwd("/home/isabel/Documents/postDoc_Amsterdam/B_BioInfo/NumericalEcology/NumEcology_BolardGilletLegendre/NEwR-2ed_code_data/NEwR2-Functions/")
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
library(ade4)
library(gclus)
library(ape)
#library(missMDA)
#library(FactoMineR)

# Source additional functions that will be used later in this
# chapter. Our scripts assume that files to be read are in
# the working directory
source("cleanplot.pca.R")
source("PCA.newr.R")
source("CA.newr.R")


BioR.theme <- theme(
  panel.background = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.line = element_line("gray25"),
  text = element_text(size = 12),
  axis.text = element_text(size = 10, colour = "gray25"),
  axis.title = element_text(size = 14, colour = "gray25"),
  legend.title = element_text(size = 14),
  legend.text = element_text(size = 14),
  legend.key = element_blank())

inName = "KraBracken_DBplusPf_062024_0.01minFrac_genus_FromPY.csv"
inName = "KraBracken_DBplusPf_082024_0minFrac_genus_FromPY.csv"
inPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/2_Metagenomics/1_taxonomy/3_FinalAbunData/"

################ LOAD DATA #######################
dataIn <- read.csv(paste(inPath, inName, sep = ""),sep = ",", header = TRUE)
dataDim <- dim(dataIn)


SpecAbund <- dataIn[1:dataDim[1],6:dataDim[2]]
SpecAbund_mat <- as.matrix(SpecAbund)
SampleInfo <- dataIn[,1:5]
SampleInfo$week <- as.character(SampleInfo$week)
Spec <- colnames(SpecAbund)

dataframe <- dataIn[,c(-1,-2,-3,-4,-5)]

# get the additional info about microbacterium and how abundant it is!
hist(SpecAbund$Microbacterium)
SampleInfo$Microbacterium <- SpecAbund$Microbacterium >= 0.2
SampleInfo$Stenotrophomonas <- SpecAbund$Stenotrophomonas >= 0.2
SampleInfo$Pseudomonas <- SpecAbund$Pseudomonas >= 0.2
SampleInfo$Paracoccus <- SpecAbund$Paracoccus >= 0.2
SampleInfo$Serratia <- SpecAbund$Serratia >= 0.01
SampleInfo$Brucella <- SpecAbund$Brucella >= 0.2

###### Prepare data and loo at it

a <- summary (dataframe)
# are there NA values?
which(is.na (SpecAbund), arr.ind = T)

image(t(SpecAbund_mat))
hist(log10(SpecAbund_mat), breaks = 100)

Spec_Abund_trafo <- decostand(SpecAbund_mat, method = "hellinger")
(PCA_trafo <- rda(Spec_Abund_trafo))
#ordiplot(PCA_trafo)


### the following is inspired by the book: Numerical Ecology with R!
## for help:
# ?cca.object

#### analyse eigenvalues:
# Eigenvalues
ev <- PCA_trafo$CA$eig
# Scree plot and broken stick model
screeplot(PCA_trafo, bstick = TRUE, npcs = length(PCA_trafo$CA$eig))
## only consider the PC that are larger than the brocken stick of same position


## get the scores = the coordiantes for the samples in the new orthonormal system
vec <- PCA_trafo$CA$v

PCA_trafo.sc0_species <- vegan::scores(PCA_trafo, c(1,2), display = "species", scaling = 0, const = c(1,1))
PCA_trafo.sc0_samples <- vegan::scores(PCA_trafo, c(1,2), display = "sites", scaling = 0, const = c(1,1))


PCA_trafo.sc1_species <- vegan::scores(PCA_trafo, display = "species", scaling = 1)
PCA_trafo.sc1_sites <- vegan::scores(PCA_trafo, display = "sites", scaling = 1)
PCA_trafo.sc2_species <- vegan::scores(PCA_trafo, display = "species", scaling = 2)
PCA_trafo.sc2_sites <- vegan::scores(PCA_trafo, display = "sites", scaling = 2)


# Plots using biplot.rda
par(mfrow = c(2, 2))
#biplot(PCA_trafo, scaling = 1, main = "PCA - scaling 1")
biplot(PCA_trafo, scaling = 0, const = c(1,10), main = "PCA - scaling 0") # Default scaling 2
biplot(PCA_trafo, scaling = 1, const = c(1,10), main = "PCA - scaling 1")
biplot(PCA_trafo, scaling = 2, const = c(3,3), main = "PCA - scaling 2") # Default scaling 2
# Plots using cleanplot.pca
# A rectangular graphic window is needed to draw the plots together
par(mfrow = c(1, 2))
cleanplot.pca(PCA_trafo, scaling = 1, mar.percent = 0.08)
cleanplot.pca(PCA_trafo, scaling = 2, mar.percent = 0.04)

# A posteriori projection of environmental variables in a PCA
# A PCA scaling 2 plot is produced in a new graphic window.
biplot(PCA_trafo, scaling = 2, main = "PCA fish abundances-scaling 2")
# Scaling 2 is default
(PCA_trafo.envit.SampleInfo <- envfit(PCA_trafo, SampleInfo[,c(2,5)], scaling = 2, const = c(1,10)))

# Plot significant variables with a user -selected colour
plot(PCA_trafo.envit.SampleInfo, p.max = 0.001 , col = 3)
# This has added the significant environmental variables to the
# last biplot drawn by R.
# BEWARE: envfit() must be g

