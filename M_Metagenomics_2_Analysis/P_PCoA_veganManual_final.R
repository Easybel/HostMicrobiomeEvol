## Script that reads the abundacy data
### this also is inspired by Numnerical Ecology in R ()

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

inName = "KraBracken_DBplusPf_062024_0.01minFrac_genus_FromPY.csv"
#inName = "KraBracken_DBplusPf_082024_0minFrac_genus_FromPY.csv"
inPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/2_Metagenomics/1_taxonomy/3_FinalAbunData/"

################ LOAD DATA #######################
dataIn <- read.csv(paste(inPath, inName, sep = ""),sep = ",", header = TRUE)
dataDim <- dim(dataIn)

spe <- dataIn[,6:dataDim[2]]
spe_mat <- as.matrix(spe)
var_all <- dataIn[,1:5]
var <-var_all[,c(2,3,5)]
var$week <- as.character(var$week)
speName <- colnames(spe_mat)

dataframe <- dataIn[,c(-1,-2,-3,-4,-5)]

# getting the bray-curtis distance and running the PCoA
spe.bray <- vegdist(spe_mat, method = "bray")
spe.b.pcoa <- cmdscale(spe.bray, k = (nrow(spe) - 1), eig = TRUE)

# Plot of the sites
sites <- vegan::scores(spe.b.pcoa, choices = c(1, 2))
## get the plot for PC1 and PC2

# Add weighted average projection of species
spe.wa <- wascores(spe.b.pcoa$points[, 1:2], spe)
spe.wa.order <- order(sqrt((spe.wa[,1]**2+spe.wa[,2]**2)), decreasing = TRUE)
speName_ordered <- speName[spe.wa.order]

spe_wa_ordered <- spe.wa[spe.wa.order,]

# A posteriori projection of environmental variables
(spe.b.pcoa.var <- envfit(spe.b.pcoa, var))

sites_pcoa  <- data.frame(var,sites)
species_pcoa <- data.frame(spe_wa_ordered)

factor_x <- 1
factor_y <- 1
plotgg1 <- ggplot() + 
  geom_vline(xintercept = c(0), color = "grey70", linetype = 2) +
  geom_hline(yintercept = c(0), color = "grey70", linetype = 2) +  
  xlab("PCA1") +
  ylab("PCA2") +  
  scale_x_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +    
  geom_point(data=sites_pcoa, 
             aes(x=Dim1, y=Dim2, colour=institution, shape=week),#, size=week))
             #aes(x=axis1, y=axis2, colour=Stenotrophomonas, shape=Pseudomonas),
             size=3) +
  BioR.theme +
  ggsci::scale_colour_npg() + 
  geom_segment(aes(x=0, y=0, xend=species_pcoa$X1[1:6]*factor_x, yend=species_pcoa$X2[1:6]*factor_y), arrow = arrow(length=unit(0.2, 'cm')) + 
  annotate("text", x=species_pcoa$X1[1:6]*factor_x, y=species_pcoa$X2[1:6]*factor_y, label=speName_ordered[1:6], color="black", size=10))
  
#coord_fixed(ratio=1)

plotgg1


plotgg1 + geom_segment(aes(x=0, y=0, xend=species_pcoa$X1[1]*factor_x, yend=species_pcoa$X2[1]*factor_y), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=species_pcoa$X1[1]*factor_x, y=species_pcoa$X2[1]*factor_y, label=speName_ordered[1], color="black", size=3) +
  
  geom_segment(aes(x=0, y=0, xend=species_pcoa$X1[2]*factor_x, yend=species_pcoa$X2[2]*factor_y), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=species_pcoa$X1[2]*factor_x, y=species_pcoa$X2[2]*factor_y, label=speName_ordered[2], color="black", size=3) + 
  
  geom_segment(aes(x=0, y=0, xend=species_pcoa$X1[3]*factor_x, yend=species_pcoa$X2[3]*factor_y), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=species_pcoa$X1[3]*factor_x, y=species_pcoa$X2[3]*factor_y*1.1, label=speName_ordered[3], color="black", size=3) + 
  
  geom_segment(aes(x=0, y=0, xend=species_pcoa$X1[4]*factor_x, yend=species_pcoa$X2[4]*factor_y), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=species_pcoa$X1[4]*factor_x*1.08, y=species_pcoa$X2[4]*factor_y, label=speName_ordered[4], color="black", size=3) + 
  
  geom_segment(aes(x=0, y=0, xend=species_pcoa$X1[5]*factor_x, yend=species_pcoa$X2[5]*factor_y), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=species_pcoa$X1[5]*factor_x*1.05, y=species_pcoa$X2[5]*factor_y, label=speName_ordered[5], color="black", size=3)+

  geom_segment(aes(x=0, y=0, xend=species_pcoa$X1[6]*factor_x, yend=species_pcoa$X2[6]*factor_y), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=species_pcoa$X1[6]*factor_x*1.05, y=species_pcoa$X2[6]*factor_y, label=speName_ordered[6], color="black", size=3)+

  geom_segment(aes(x=0, y=0, xend=species_pcoa$X1[7]*factor_x, yend=species_pcoa$X2[7]*factor_y), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=species_pcoa$X1[7]*factor_x*1.2, y=species_pcoa$X2[7]*factor_y*2, label=speName_ordered[7], color="black", size=3)





