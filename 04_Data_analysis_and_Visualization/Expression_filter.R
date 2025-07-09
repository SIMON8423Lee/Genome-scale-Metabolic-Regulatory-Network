library(tidyverse)
RPKM <- read.table("All_FPKM.txt",header = T, row.names = 1,check.names = F)
df1 <- RPKM[rowSums(RPKM)>0,]
df2 <- df1[rowSums(df1>=1)>=4,]
df3 <- df2[,colSums(df2>=1)>=10000]
write.table(df3, file = "RPKM_filter.txt", quote = F, sep = '\t', row.names = T, col.names = T)