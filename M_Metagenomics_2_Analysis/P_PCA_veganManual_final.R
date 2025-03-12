## Script thatcreates a PCA of the species abundancy data 

### install packages and load them
library(pheatmap)
library(ggplot2)
library(vegan)
#library(labdsv)
#library(readxl)
#library(ggsci)
#library(ggforce)
#library(ggrepel) 
#library(BiodiversityR)

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

## comment 
# -- the sum of abundancies of each sample is not 1, becaue I made a cut off
###################################################

# pre-transforming the data with hellinger transform 
Spec_Abund_trafo <- decostand(spe_mat, method = "hel") # scaling = TRUE, method = "norm", "chi.square"
pca_trafo <- rda(Spec_Abund_trafo)

## get the plot for PC1 and PC2 -- first overview
plot1 <- ordiplot(pca_trafo, choices=c(1,2))

#### analyse the loadings -> entries of the eigenvectors
# use scaling = 2 because it yields a correlation figure
PCA_trafo.sc2_loading <- vegan::scores(pca_trafo, c(1,2,3,4), display = "species", scaling = 2)
PCA_trafo.sc2_scores  <- vegan::scores(pca_trafo, c(1,2,3,4), display = "sites", scaling = 2)

pca_order <- order(sqrt(PCA_trafo.sc2_loading[,1]**2+PCA_trafo.sc2_loading[,2]**2), decreasing = TRUE) # this is based on the first component

speName_ord <- speName[pca_order]
load_PCA_ord <- data.frame(speName_order,PCA_trafo.sc2_loading[pca_order,])
scores_PCA   <- data.frame(var,PCA_trafo.sc2_scores) # with variable names
(ev <- pca_trafo$CA$eig)

### Plot the PCA
plotgg1 <- ggplot() + 
  geom_vline(xintercept = c(0), color = "grey70", linetype = 2) +
  geom_hline(yintercept = c(0), color = "grey70", linetype = 2) +  
  xlab(paste("PCA1 (",as.character(round(100*ev[1]/sum(ev)),1)," %)", sep = "")) +
  ylab("PCA2") +  
  scale_x_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +    
  geom_point(data=scores_PCA, 
             aes(x=PC1, y=PC2, colour=institution, shape=week),#, size=week))
             #aes(x=axis1, y=axis2, colour=Stenotrophomonas, shape=Pseudomonas),
             size=3) +
  BioR.theme +
  ggsci::scale_colour_npg()

plotgg1
factor_x <- 0.3
factor_y <- 0.3

plotgg1 + geom_segment(aes(x=0, y=0, xend=load_PCA_ord$PC1[1]*factor_x, yend=load_PCA_ord$PC2[1]*factor_y), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=load_PCA_ord$PC1[1]*factor_x, y=load_PCA_ord$PC2[1]*factor_y*1.5, label=load_PCA_ord$speName_order[1], color="black", size=3) +
  
  geom_segment(aes(x=0, y=0, xend=load_PCA_ord$PC1[2]*factor_x, yend=load_PCA_ord$PC2[2]*factor_y), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=load_PCA_ord$PC1[2]*factor_x*1.1, y=load_PCA_ord$PC2[2]*factor_y, label=load_PCA_ord$speName_order[2], color="black", size=3) + 
  
  geom_segment(aes(x=0, y=0, xend=load_PCA_ord$PC1[3]*factor_x, yend=load_PCA_ord$PC2[3]*factor_y), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=load_PCA_ord$PC1[3]*factor_x, y=load_PCA_ord$PC2[3]*factor_y*1.1, label=load_PCA_ord$speName_order[3], color="black", size=3) + 
  
  geom_segment(aes(x=0, y=0, xend=load_PCA_ord$PC1[4]*factor_x, yend=load_PCA_ord$PC2[4]*factor_y), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=load_PCA_ord$PC1[4]*factor_x*1.08, y=load_PCA_ord$PC2[4]*factor_y*1.2, label=load_PCA_ord$speName_order[4], color="black", size=3) + 
  
  geom_segment(aes(x=0, y=0, xend=load_PCA_ord$PC1[5]*factor_x, yend=load_PCA_ord$PC2[5]*factor_y), arrow = arrow(length=unit(0.2, 'cm'))) + 
  annotate("text", x=load_PCA_ord$PC1[5]*factor_x*1.05, y=load_PCA_ord$PC2[5]*factor_y*1.1, label=load_PCA_ord$speName_order[5], color="black", size=3)





