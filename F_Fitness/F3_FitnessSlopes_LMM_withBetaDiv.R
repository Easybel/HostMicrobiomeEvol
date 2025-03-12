library(ggplot2)
library(lme4)
library(flexplot)
data(math)

inFit = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/2_Analysis/df_wMeta_FitnessPairs_w1to15_woNegFitness.RData"
inFit_single = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/2_Analysis/df_wMeta_notexpand_FitnessPairs_w1to15_woNegFitness.RData"
################ LOAD DATA #######################

a = load(inFit)
b = load(inFit_single)

df_wMeta_notexpand$treatmentBB <- df_wMeta_notexpand$treatment == "bb"
################## somehow it is not working, exclude data:
df_wMeta_notexpand <- df_wMeta_notexpand[df_wMeta_notexpand$inst_treat!="NIOO_A00",]

df_wMeta_notexpand <- df_wMeta_notexpand[(df_wMeta_notexpand$institution!="RUG" & df_wMeta_notexpand$institution!="WUR"),]

#########################################################


## overview of the fitness 
ggplot(df_wMeta_notexpand, aes(x=inst_treat, y=slope)) + 
  geom_boxplot()+
  geom_jitter()

ggplot(df_wMeta_notexpand, aes(x=betadiver, y=slope, )) +
  geom_point() + 
  facet_wrap(~treatmentBB) + 
  geom_smooth(method=lm, se=FALSE)




# Step 1: Fit a baseline model ---------------------------------------------
## perform a random effects anova, where we just ask if the fitness differs between clusters!
# ----- fit fixed slope and random slope

baseline = lmer(slope ~ 1 + (1|institution), data = df_wMeta_notexpand)
visualize(baseline, plot="model")

# Step 2: Compute the ICC ------------------------------------------------
icc(baseline)
visualize(baseline)
# for lmer(slope ~ 1 + (1|institution), data = df_wMeta_notexpand)::: 

##  -- 33% of variance due to groups

mod1 = lmer(slope ~ betadiver + (betadiver|institution), data = na.omit(df_wMeta))
mod3 = lmer(slope ~ betadiver + institution + (betadiver|institution), data = na.omit(df_wMeta_notexpand))

visualize(mod2, plot="model")
summary(mod1)
############ the naivest thing we can do -- linear regression
fm2 <- lm(slope ~ betadiver + institution + treatment, df_wMeta_notexpand)
summary(fm2)

intercept0 <- fm2$coefficients[1]
slope0 <-  fm2$coefficients[2]
df_wMeta$fit0 <- df_wMeta$betadiver * slope0 + intercept0

plot0 <- ggplot(data = df_wMeta, aes(x=betadiver, y= slope, color=institution))+
  geom_jitter()+
  geom_line(aes(x=betadiver, y=fit0))
plot0

