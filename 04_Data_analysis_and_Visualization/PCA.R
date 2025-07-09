library(psych)
library(reshape2)
library(ggplot2)
library(factoextra)
library(corrplot)
exprData <- "../Meta_mat_mean.txt"
sampleFile <- "samplelist_forPCA"
data <- read.table(exprData, header=T, row.names=NULL,sep="\t")
rownames_data <- make.names(data[,1],unique=T)
data <- data[,-1,drop=F]
rownames(data) <- rownames_data
data <- data[rowSums(data)>0,]
data <- data[apply(data, 1, var)!=0,]
mads <- apply(data, 1, mad)
data <- data[rev(order(mads)),]
data_t <- t(data)
variableL <- ncol(data_t)
if(sampleFile != "") {
  sample <- read.table(sampleFile,header = T, row.names=1,sep="\t")
  data_t_m <- merge(data_t, sample, by=0)
  rownames(data_t_m) <- data_t_m$Row.names
  data_t <- data_t_m[,-1]
}
pca <- prcomp(data_t[,1:variableL], scale=F)
percentVar <- pca$sdev^2 / sum( pca$sdev^2)
print(str(pca))
fviz_eig(pca, addlabels = TRUE)
fviz_pca_ind(pca, repel=T)   
fviz_pca_ind(pca, col.ind=data_t$conditions, mean.point=F, palette = c("#8b75fd", "#f75f6c"), geom = c("point", "text"), repel = T,
             addEllipses = T, col.var = "steelblue", title = "PCA", legend.title="Groups")