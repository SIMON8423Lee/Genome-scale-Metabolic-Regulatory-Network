library(ComplexHeatmap)
library(circlize)
library(magick)
dt <- read.table("Gene_Cluster.txt",header = T,row.names = 1,sep = '\t')
dim(dt)
annotation_row <- dt[,51]
annotation_row <- as.data.frame(annotation_row)
row.names(annotation_row) <- rownames(dt)
colnames(annotation_row) <- 'Class'
dim(dt)
range(dt)
n=t(scale(t(dt)))
n[n>2]=2 
n[n< -2]= -2 
n <- as.matrix(n)
ann_colors = list(
  Class = c(cluster1 ="#66C2A5", cluster2="#FC8D62",cluster3="#8DA0CB",cluster4="#E78AC3",cluster5="#F0027F", cluster6="#FFD92F",
            cluster7="#8DD3C7", cluster8="#1F78B4",cluster9="#8126C0"))
A <- pheatmap(n, show_rownames = F,
              #col = col_fun3,
              show_colnames = T,
              #col = colorRampPalette(c("#6EA6CD","#EAECCC","#F67E4B"))(100),
              #annotation_col = annotation_col, 
              annotation_row = annotation_row,
              #row_split = annotation_row$Pathway,
              #column_split = annotation_col$group,
              annotation_names_row = T,
              annotation_names_col = F ,
              annotation_colors = ann_colors,
              column_title = NULL,
              row_title = NULL,
              cluster_cols  = FALSE,
              cluster_rows  = F)
