## In this script, we get the increase of fitness
##   between w1 and w15 for growth rate:
#

library(ggplot2)
library(readxl)

## Get data:
#load the data
inPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/2_Analysis/"
inName = "Fitness_Slope_wError_df_Pairs_w1to15_woNegFitness.RData"
outPath = "/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/2_Analysis/"

a = load(paste(inPath, inName, sep = ""))
df_Pairs_w0_1to15 <- get(a)
rm(a)

## exclude the data that we don't want:
## ## ## -- for VU bb we have week0 and week1, but we only want to keep week1 vs week 15
df_Pairs_w0_1to15 <- df_Pairs_w0_1to15[!(df_Pairs_w0_1to15$inst_treat=="VU_bb" & df_Pairs_w0_1to15$week_start==0),]
df_Pairs_w0_1to15 <- df_Pairs_w0_1to15[!(df_Pairs_w0_1to15$inst_treat=="RUG_bb" & df_Pairs_w0_1to15$week_start==0),]

##########################################################
##########################################################
fitness_slope <- df_Pairs_w0_1to15$collectMean
m1 <- aov(collectMean ~ treatment+institution, data=df_Pairs_w0_1to15)
summary(m1)

plot1 <- ggplot(data = df_Pairs_w0_1to15, aes(x = treatment, y = collectMean, fill = institution)) +
  geom_boxplot()+
  geom_jitter(aes(color = institution), alpha = 0.7, )
plot1



############################## expand the data frame!! #######################
## that means that I want each slope on a separate line 

slopeNum <- c()
for (i in 1:dim(df_Pairs_w0_1to15)[1]) {
  slopeNum[i] <- length(df_Pairs_w0_1to15$collectSlope[[i]])
}

df_expand <- data.frame(matrix(ncol = 8, nrow = sum(slopeNum)))
x <- c(colnames(df_Pairs_w0_1to15)[1:7], "slope")
colnames(df_expand) <- x



k = 0
for (i in 1:dim(df_Pairs_w0_1to15)[1]) {
  
  slopeNum <- length(df_Pairs_w0_1to15$collectSlope[[i]])
  for (j in 1:slopeNum){
    k <- k +1
    df_expand[k,] <- c(df_Pairs_w0_1to15[i,1:7], df_Pairs_w0_1to15$collectSlope[[i]][j])
  }
}
df_expand$slope <- as.numeric(df_expand$slope)

plot2 <- ggplot(data = df_expand, aes(x = institution, y = slope))+ #, fill = treatment)) +
  geom_boxplot(alpha = 1)+
  geom_jitter(aes(color = ID),alpha=1) +
  theme_bw() + 
  xlab("") + 
  ylab("fitness slope")
plot2


#### also get the data where you don't expand 
drop_fromPairs <- c("sampleIdx_start","sampleIdx_end","simpleMean_start","simpleMean_end")
df_notexpanded <- df_Pairs_w0_1to15[-c(8:12)]
names(df_notexpanded)[names(df_notexpanded) == "collectMean"] <- "slope"

###### save the output
save(df_expand,  file = paste(outPath,"df_expand_FitnessPairs_w1to15_woNegFitness.RData", sep = ""))
save(df_notexpanded,  file = paste(outPath,"df_notexpand_FitnessPairs_w1to15_woNegFitness.RData", sep = ""))


