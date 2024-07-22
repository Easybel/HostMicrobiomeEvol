library(ggplot2)
library(lme4)
library(flexplot)
data(math)
library(car)
library(rstatix)

## load data
inFit = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/2_Analysis/df_wMeta_FitnessPairs_w1to15_woNegFitness.RData"
inFit_single = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/2_Analysis/df_wMeta_notexpand_FitnessPairs_w1to15_woNegFitness.RData"
a = load(inFit)
b = load(inFit_single)

## expand the data and delete some samples if needed
df_wMeta_notexpand$treatmentBB <- df_wMeta_notexpand$treatment == "bb"

################## somehow it is not working, exclude data:
#df_wMeta_notexpand <- df_wMeta_notexpand[df_wMeta_notexpand$inst_treat!="NIOO_A00",]

#df_wMeta_notexpand <- df_wMeta_notexpand[(df_wMeta_notexpand$institution!="RUG" & df_wMeta_notexpand$institution!="WUR"),]
#########################################################

df_wMeta_notexpand$treatment <- factor(df_wMeta_notexpand$treatment)
df_wMeta_notexpand$institution <- factor(df_wMeta_notexpand$institution)

#### 1. Answer the question:
## How much variation in the fitness data is explained by groups? 
#######################################################

## overview of the fitness 
ggplot(df_wMeta_notexpand, aes(x=inst_treat, y=slope)) + 
  geom_boxplot() + 
  geom_jitter(aes(x=inst_treat, y=slope, color=ID))

## --> it already looks like grouping makes a difference mainly for VU_bn50


## -- perform Anova
### for an unbalanced design
aggregate(slope ~ institution + treatment, df_wMeta_notexpand, mean)
xtabs(~ institution + treatment, df_wMeta_notexpand)
xtabs(~ inst_treat, df_wMeta_notexpand)

model_null <- lm(slope ~ 1, data = df_wMeta_notexpand)
anova(model_null)
model_treatment <- lm(slope ~ treatment, data = df_wMeta_notexpand)
anova(model_treatment)
model_both <- lm(slope ~ treatment + institution, data = df_wMeta_notexpand)
anova(model_both)
model_inst_treat <- aov(slope ~ inst_treat, data = df_wMeta_notexpand)
anova(model_inst_treat)
## for the interaction it somehow doesnt evaluate the interactio term ... hmm weird
model_interaction <- lm(slope ~ institution*treatment, data = df_wMeta_notexpand)
anova(model_interaction)


## which is the best model?

## for example use:  Akaike information criterion (AIC)
## --Y it is a good test for model fit & calculates the information value of 
## each model by balancing the variation explained against the number of parameters used.
## model with the lowest AIC score (listed first in the table) is the best fit for the data:
library(AICcmodavg)

model.set <- list(model_null, model_treatment, model_both, model_inst_treat, model_interaction)
model.names <- c("ano_null", "treatment", "both", "inst_treat","interaction")

aictab(model.set, modnames = model.names)

## or use the anova command 
anova(model_null, model_treatment, model_both, model_interaction, model_inst_treat, test="Chisq")

########   take care of the fact that we have a highly unbalanced desgn 
# -- use the type 2 method
mod_unbalanced <- lm( slope ~  inst_treat, df_wMeta_notexpand )
Anova(mod_unbalanced, type = 2)



## check for homoscedasticity

par(mfrow=c(2,2))
plot(model_inst_treat)
par(mfrow=c(1,1))

## Do a post-hoc Turkey test
tukey.model_inst_treat <-TukeyHSD(model_inst_treat)
modelALL_inst_treat <- aov(slope ~ inst_treat, data = df_wMeta)
tukey.modelALL_inst_treat <-TukeyHSD(modelALL_inst_treat)

tukey.model_inst_treat
tukey.modelALL_inst_treat

## or rather do a Games-Howell test that doesn't care about unequal variance
# ---- but it wont run for y <- games_howell_test(df_wMeta, slope ~ inst_treat)
# ---->> maybe not enough data??
y <- games_howell_test(df_wMeta, slope ~ inst_treat)
y




