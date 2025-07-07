library(factoextra)
library(cluster)
##########################################################Analysis
genemeta <- read.table("gene.txt",header =T,row.names=1,sep="\t")
dim(genemeta)
fviz_nbclust(genemeta, kmeans, k.max = 30, method = "wss")
#calculate gap statistic based on number of clusters
gap_stat <- clusGap(genemeta,
                    FUN = kmeans,
                    nstart = 25,
                    K.max = 30,
                    B = 50)
#plot number of clusters vs. gap statistic
fviz_gap_stat(gap_stat)
set.seed(1)
#kmeans
k = 9
km <- kmeans(genemeta, centers = 9, nstart = 25)
#plot results of final k-means model
fviz_cluster(km, data = genemeta)
#find means of each cluster
aggregate(genemeta, by=list(cluster=km$cluster), mean)
#add cluster assigment to original data
final_data <- cbind(genemeta, cluster = km$cluster)
#view final data
head(final_data)
#write data
write.table(final_data, file = "cluster.txt", sep = '\t', quote =F, row.names = T)