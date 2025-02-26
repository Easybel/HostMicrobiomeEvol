## Script that reads the abundacy data

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

inName = "Mock_MetagenomePCAdata_woNoise.RData"
inPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/2_Metagenomics/3_PCA/mock_Metagenome_data/"

################ LOAD DATA #######################
load(paste(inPath, inName, sep = ""))
dataDim <- dim(df)


SpecAbund <- df[1:dataDim[1],3:dataDim[2]]
SpecAbund <- df[1:dataDim[1],3:18] # exclude the zeros
SpecAbund_mat <- as.matrix(SpecAbund)
SampleInfo <- df[,1:2]
#SampleInfo$week <- as.character(SampleInfo$week)
#Spec <- df[1,3:dataDim[2]]

dataframe <- df[,c(-1,-2)]
#rownames(dataframe) <- SampleInfo[,1]


###### Prepare data and loo at it

a <- summary (dataframe)
# are there NA values?
which (is.na (SpecAbund), arr.ind = T)

image (t(SpecAbund_mat))
hist(log10(SpecAbund_mat), breaks = 100)
hist(SpecAbund_mat, breaks = 100)

Spec_Abund_trafo <- decostand(SpecAbund_mat, method = "hellinger")
#Spec_Abund_trafo <- SpecAbund_mat
PCA_trafo <- rda(Spec_Abund_trafo)
#ordiplot(PCA_trafo)

## get the plot for PC1 and PC2

plot1 <- ordiplot(PCA_trafo, choices=c(1,2))

sites.long1 <- sites.long(plot1, env.data=SampleInfo)
head(sites.long1)
plotgg1 <- ggplot() + 
  geom_vline(xintercept = c(0), color = "grey70", linetype = 2) +
  geom_hline(yintercept = c(0), color = "grey70", linetype = 2) +  
  xlab("PCA1") +
  ylab("PCA2") +  
  scale_x_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +    
  geom_point(data=sites.long1, 
             aes(x=axis1, y=axis2, colour=samples), 
             size=3) +
  BioR.theme +
  ggsci::scale_colour_npg()
  #coord_fixed(ratio=1)

plotgg1

## get the plot for PC3 and PC4

plot2 <- ordiplot(PCA_trafo, choices=c(3,4))

sites.long2 <- sites.long(plot2, env.data=SampleInfo)
head(sites.long2)
plotgg2 <- ggplot() + 
  geom_vline(xintercept = c(0), color = "grey70", linetype = 2) +
  geom_hline(yintercept = c(0), color = "grey70", linetype = 2) +  
  xlab("PCA3") +
  ylab("PCA4") +  
  scale_x_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +    
  geom_point(data=sites.long2, 
             aes(x=axis1, y=axis2, colour=samples), 
             size=3) +
  BioR.theme +
  ggsci::scale_colour_npg()
#coord_fixed(ratio=1)

plotgg2

