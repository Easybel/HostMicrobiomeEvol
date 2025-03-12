## this is Thomas' script about how to get fitness outliers
library(ggplot2)
library(car)


path="/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/2_Fitness/"
repeatability<-read.csv(paste(path,"Celfitnessrepeatability_April2024.csv", sep = ""))
repeatability$label<-factor(repeatability$label)
repeatability$treat.group<-factor(repeatability$treat.group)
repeatability$replicate<-factor(repeatability$replicate)
repeatability$lab<-factor(repeatability$lab)


ggplot(repeatability[repeatability$treat.group=="BB",], aes(x=lab, y=growth_nematode_m, group=replicate, color=serieperson)) +
  geom_point(position = position_dodge(width=0.8)) +
  geom_line(position = position_dodge(width=0.8)) +
  facet_wrap(~lab*treatment, scale="free_x") +
  scale_color_viridis_d() +
  theme_bw()


## plot shows separate counts in different colors, each panel is a lab and in each panel the rows are the biological replicates (5 for all labs, except WUR)
ggplot(repeatability[repeatability$treat.group=="BB",], aes(x=lab, y=growth_nematode_m, group=serieperson , color=replicate)) +
  geom_point(position = position_dodge(width=0.8)) +
  geom_line(position = position_dodge(width=0.8)) +
  facet_wrap(~lab*treatment, scale="free_x") +
  scale_color_viridis_d() +
  theme_bw()


## plot shows replicates in different colors, each panel is a lab and in each panel the rows are the counting series (1-3 per lab)
## main take-away: unequal numbers of count (technical) replicates, therefore, subsampling is needed
### how the subsampling works: 100 times pick 1 fitness meaurement per replicate in each treatment
## ## ## output: 100 lists that have 48 items and each replicate appears once

seed.vector <- sample(x=c(1:10000),size=100)
df.list <- NULL
label.vector <- levels(repeatability$label) # there are this many unique labels

# create k=100 lists
for(k in 1:100){
  df.adj <- NULL
  # for each k go over all i labels
  for(i in 1:length(label.vector)){
    df <- repeatability[repeatability$label==paste(label.vector[i]),]
    if(nrow(df)>1){
      set.seed(seed.vector[k])
      j = sample(x=c(1:nrow(df)),size=1)
      df.adj <- rbind(df.adj,df[j,])
    }else{
      df.adj <- rbind(df.adj,df)
    }}
  df.list[[k]] <- df.adj
}


# save(df.list,file="subset_list_variance.Rdata")
# save(seed.vector,file="seeds_variance.Rdata")
# load("subset_list_variance.Rdata")
sensitivityF <- NULL
for(i in 1:length(df.list)){
  test1 <- car::leveneTest(abs(growth_nematode_m)~lab,data=df.list[[i]][df.list[[i]]$treat.group=="BB",])
  test.primary.value <- test1$`F value`[1]
  test2 <- car::leveneTest(growth_nematode_m~lab,data=df.list[[i]][df.list[[i]]$treat.group=="ZVAR",])
  test.secondary.value <- test2$`F value`[1]
  res <- rbind(test.primary.value,test.secondary.value)
  sensitivityF <- rbind(sensitivityF,res)
}

