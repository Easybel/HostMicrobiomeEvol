library(ggplot2)
library(lme4)
library(flexplot)
data(math)

baseline = lmer(MathAch ~ 1 + (1 | School), data = math)
visualize(baseline)
math$School <- factor(math$School)
math$SES <- factor(math$School)


ggplot(math, aes(x=School, y=MathAch)) + 
  geom_boxplot(aes(x=School, y=MathAch)) 
  #geom_jitter(aes(x=School, y=MathAch, color=SES))

mod1 = lmer(MathAch ~ SES + (SES | School), data = math)
visualize(mod1, plot="model")


model_null <- lm(MathAch ~ 1, data = math)
anova(model_null)
model_institution <- lm(MathAch ~ School, data = math)
anova(model_institution)
model_both <- lm(MathAch ~ Sex + School, data = math)
anova(model_both)

## for the interaction it somehow doesnt evaluate the interactio term ... hmm weird
model_interaction <- lm(MathAch ~ Sex + School + Sex:School, data = math)
anova(model_interaction)

xtabs(~Sex + School, math)
