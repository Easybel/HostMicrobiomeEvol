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

inName = "KraBracken_DBstandard_042024_0minFrac_genus_FromPY.csv"
inName = "KraBracken_DBplusPf_062024_0.01minFrac_genus_FromPY.csv"
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
PCA_trafo <- rda(Spec_Abund_trafo)
summary(PCA_trafo)
#ordiplot(PCA_trafo)

## get the plot for PC1 and PC2

plot1 <- ordiplot(PCA_trafo, choices=c(1,2)) 
plot1
#+ ordiellipse(PCA_trafo, groups = SampleInfo$institution)
#### analyse the eigenvectors!!

vec <- PCA_trafo$CA$v
vec_PC1 <- vec[,1]
vec_PC2 <- vec[,2]
vec_PC3 <- vec[,3]
vec_PC4 <- vec[,4]

order_PC1 <- order(abs(vec_PC1))
SpecOI_PC1 <- Spec[order_PC1[1245:1249]]
CompOI_PC1 <- vec_PC1[order_PC1[1245:1249]] 
CompOI_PC2 <- vec_PC2[order_PC1[1245:1249]] 
CompOI_PC3 <- vec_PC3[order_PC1[1245:1249]] 

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
             aes(x=axis1, y=axis2, colour=institution, shape=week),#, size=week))
             #aes(x=axis1, y=axis2, colour=Stenotrophomonas, shape=Pseudomonas),
             size=3) +
  BioR.theme +
  ggsci::scale_colour_npg()
  #coord_fixed(ratio=1)
plotgg1
## make the ellipses

CompOI_PC1 <- CompOI_PC1*0.7
CompOI_PC2 <- CompOI_PC2*0.7

## get the coordinates for different subsamples
sites_w01 <- sites.long1[(sites.long1$week=="0" | sites.long1$week=="1") ,]
sites_w15 <- sites.long1[(sites.long1$week=="15"),]


plotgg1 + geom_segment(aes(x=0, y=0, xend=CompOI_PC1[1], yend=CompOI_PC2[1]), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=CompOI_PC1[1]*1, y=CompOI_PC2[1]*1.8, label=SpecOI_PC1[1], color="black", size=2.2) + 
  
  geom_segment(aes(x=0, y=0, xend=CompOI_PC1[2], yend=CompOI_PC2[2]), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=CompOI_PC1[2]*1, y=CompOI_PC2[2]*1.4, label=SpecOI_PC1[2], color="black", size=2.2) + 
  
  geom_segment(aes(x=0, y=0, xend=CompOI_PC1[3], yend=CompOI_PC2[3]), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=CompOI_PC1[3]*1, y=CompOI_PC2[3]*1.1, label=SpecOI_PC1[3], color="black", size=2.2) + 
  
  geom_segment(aes(x=0, y=0, xend=CompOI_PC1[4], yend=CompOI_PC2[4]), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=CompOI_PC1[4]*0.85, y=CompOI_PC2[4]*1.3, label=SpecOI_PC1[4], color="black", size=2.2) + 
  
  geom_segment(aes(x=0, y=0, xend=CompOI_PC1[5], yend=CompOI_PC2[5]), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=CompOI_PC1[5]*0.87, y=CompOI_PC2[5]*1.2, label=SpecOI_PC1[5], color="black", size=2.2) + 
  #stat_ellipse(level = 0.95, data=sites.long1[sites.long1$week=="15",], 
  #             aes(x=axis1, y=axis2, colour=institution), alpha = 0.5)
  stat_ellipse(level = 0.95, data=sites_w15, 
             aes(x=axis1, y=axis2, colour=institution), alpha = 1)


