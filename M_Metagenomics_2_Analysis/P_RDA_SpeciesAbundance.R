# in this script, perform RDA
## based on the book (Numerical Ecology in R)
## for the species abundance data vs the explanatory variables

setwd("/home/isabel/Documents/postDoc_Amsterdam/B_BioInfo/NumericalEcology/NumEcology_BolardGilletLegendre/NEwR-2ed_code_data/NEwR2-Functions/")

library(ade4)
library(adegraphics)
#library(adespatial)
library(vegan)
library(vegan3d)
library(MASS)
library(ellipse)
library(FactoMineR)
library(rrcov)

# Source additional functions that will be used later in this
# Chapter. Our scripts assume that files to be read are in
# the working directory.
source("hcoplot.R")
source("triplot.rda.R")
source("plot.lda.R")
source("polyvars.R")
source("screestick.R")

# Load the species data that already includes the variables

inName = "KraBracken_DBplusPf_062024_0.01minFrac_genus_FromPY.csv"
#inName = "KraBracken_DBplusPf_082024_0minFrac_genus_FromPY.csv"
inPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/2_Metagenomics/1_taxonomy/3_FinalAbunData/"

################ LOAD DATA #######################
dataIn <- read.csv(paste(inPath, inName, sep = ""),sep = ",", header = TRUE)
dataDim <- dim(dataIn)


spec <- dataIn[,6:dataDim[2]]
spec_mat <- as.matrix(spec)
var_all <- dataIn[,1:5]
var <-var_all[,c(2,3,5)]
var$week <- as.character(var$week)
specName <- colnames(spec_mat)

dataframe <- dataIn[,c(-1,-2,-3,-4,-5)]
# Hellinger-transform the species data set
spe.hel <- decostand(spec, "hellinger")

# perform the rda on all variables that are included in var
(spe.rda <- rda(spe.hel ~ institution + week + treatment, var))
(summary(spe.rda))   # Scaling 2 (default))

# Unadjusted R^2 retrieved from the rda object
(R2 <- RsquareAdj(spe.rda)$r.squared)
# Adjusted R^2 retrieved from the rda object
(R2adj <- RsquareAdj(spe.rda)$adj.r.squared)

# Scaling 1
plot(spe.rda,
     scaling = 1,
     display = c("sp", "lc", "cn"),
     main = "Triplot RDA spe.hel ~ env3 - scaling 1 - lc scores"
)
spe.sc1 <-
  vegan::scores(spe.rda,
         choices = 1:2,
         scaling = 1,
         display = "sp"
  )
arrows(0, 0,
       spe.sc1[, 1] * 0.92,
       spe.sc1[, 2] * 0.92,
       length = 0,
       lty = 1,
       col = "red"
)

# retrieve the species scores
#spe_scores <- vegan::scores(spe.rda, display = "species", scaling = 2)
#site_scores <- vegan::scores(spe.rda, display = "sites", scaling = 2)


## Global test of the RDA result
anova(spe.rda, permutations = how(nperm = 999))
## Tests of all canonical axes - how many are significant?
anova(spe.rda, by = "axis", permutations = how(nperm = 999))

# RDA with all explanatory variables except dfs
spe.rda.all <- rda(spe.hel ~ ., data = var)
# Global adjusted R^2
(R2a.all <- RsquareAdj(spe.rda.all)$adj.r.squared)

#### We want to reduce the number of variables, 
## reasons: parsimony, or collinear behavior
 # Linear dependencies can be explored by computing the X variables’ variance
 #inﬂation factors (VIF), which measure to what extent each variable in a data set X is
 #collinear with the others. High VIFs are found when two variables are highly
 #intercorrelated or when one variable is a strong linear combination of several others.
 #VIF values above 20 indicate strong collinearity. Ideally, VIFs above 10 should be at
 #least examined, and avoided if possible.

#vif <- diag(solve(cor(var))) -- only works with numveric data
# Variance inflation factors (VIF) in two RDAs
# First RDA of this Chapter: all environmental variables
# except dfs
vif.cca(spe.rda)


# Forward selection using vegan's ordistep()
# This function allows the use of factors.
mod0 <- rda(spe.hel ~ 1, data = var)
step.forward <-
  ordistep(mod0,
           scope = formula(spe.rda.all),
           direction = "forward",
           permutations = how(nperm = 499)
  )
RsquareAdj(step.forward)


############## manually

# perform the rda on all variables that are included in var
(spe.rda_inst <- rda(spe.hel ~ institution, var))
(R2adj_inst <- RsquareAdj(spe.rda_inst)$adj.r.squared)

(spe.rda_week <- rda(spe.hel ~ week, var))
(R2adj_week <- RsquareAdj(spe.rda_week)$adj.r.squared)

(spe.rda_treat <- rda(spe.hel ~ treatment, var))
(R2adj_inst <- RsquareAdj(spe.rda_treat)$adj.r.squared)

#---> institution explains most!!! Select: istitution and combine it with the others

(spe.rda_inst_week <- rda(spe.hel ~ institution + week, var))
(R2adj_inst_week <- RsquareAdj(spe.rda_inst_week)$adj.r.squared)

(spe.rda_inst_treat <- rda(spe.hel ~ institution + treatment, var))
(R2adj_inst_treat <- RsquareAdj(spe.rda_inst_treat)$adj.r.squared)

#---> institution+week is best!!

# final question: does treatment  still add?

(spe.rda_inst_week_treat <- rda(spe.hel ~ institution + week + treatment, var))
(R2adj_inst_week_treat <- RsquareAdj(spe.rda_inst_treat_week)$adj.r.squared)

#---> YES!! but is this really true? Because with more variables, there is inflation of R²
## test this!

anova(spe.rda_inst_week_treat,spe.rda_inst)

