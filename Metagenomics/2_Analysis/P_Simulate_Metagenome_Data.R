

# create mock-etagenomic data!
outPath="/home/isabel/Documents/postDoc_Amsterdam/1_EvolWormJourney/1_Genomics/2_EvolGenomics/2_Metagenomics/3_PCA/mock_Metagenome_data/"
outName="Mock_MetagenomePCAdata_wHighNoise.RData"

# how should the data look?
spec_total=100
spec_inA=5
spec_inB=5
spec_inC=5
samples_typeA=5
samples_typeB=5
samples_typeC=5
samples_all = samples_typeA + samples_typeB + samples_typeC

#noise <- 11 # normal noise
noise <- 101 # high noise

samples=c(rep("SampleA",samples_typeA),rep("SampleB",samples_typeB),rep("SampleC",samples_typeC))
replicates = c(rep(c(1,2,3,4,5),3))

# loop over samples_all and fill up a matrix that can be converted to a dataframe
mat = matrix(NA, nrow = samples_all, ncol = spec_total)

for (i in 1:samples_typeA) {
  randNum <- floor(runif(spec_inA, min=0, max=11)) # random numbers to 10
  randNum_wOffset <- randNum * 100
  row <- c( sort(randNum_wOffset,decreasing=TRUE), rep(0,spec_total-spec_inA))
  row_wNoise <- row + floor(runif(spec_total, min=0, max=noise)) 
  row_wNoise_rel <- row_wNoise / sum(row_wNoise)
  
  # write to matrix
  mat[i,] <- row_wNoise_rel
} 

for (i in 1:samples_typeB) {
  randNum <- floor(runif(spec_inB, min=0, max=11)) # random numbers to 10
  randNum_wOffset <- randNum * 100
  row <- c(rep(0,spec_inA), sort(randNum_wOffset,decreasing=TRUE), rep(0,spec_total-spec_inA - spec_inB))
  row_wNoise <- row + floor(runif(spec_total, min=0, max=noise ))
  row_wNoise_rel <- row_wNoise / sum(row_wNoise)
  
  # write to matrix
  idx <- samples_typeA+i
  mat[idx,] <- row_wNoise_rel
} 

for (i in 1:samples_typeC) {
  randNum <- floor(runif(spec_inC, min=0, max=11)) # random numbers to 10
  randNum_wOffset <- randNum * 100
  row <- c(rep(0,spec_inA+spec_inB), sort(randNum_wOffset,decreasing=TRUE), rep(0,spec_total-spec_inA - spec_inB - spec_inC))
  row_wNoise <- row + floor(runif(spec_total, min=0, max=noise))
  row_wNoise_rel <- row_wNoise / sum(row_wNoise)
  
  # write to matrix
  idx <- samples_typeB + samples_typeA +i
  mat[idx,] <- row_wNoise_rel
} 

##  save as data
d <- as.data.frame(mat)
df <- cbind(samples, replicates,d)

save(df, file = paste(outPath,outName,sep = "")) 

