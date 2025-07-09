A<- read.table("R_cor_Cluster_final_1_sign_all_rsort.ID",header=T,sep='\t')
B<- read.table("R_cor_Cluster_final_2_sign_all_rsort.ID",header=T,sep='\t')
C <- read.table("R_cor_Cluster_final_3_sign_all_rsort.ID",header=T,sep='\t')
D <- read.table("R_cor_Cluster_final_4_sign_all_rsort.ID",header=T,sep='\t')
A <- A[-1,]
B <- B[-1,]
C <- C[-1,]
D <- D[-1,]
library(VennDiagram)
pdf(file="p1.GenusVenn.pdf", width=4, height=3, pointsize=8)
venn.plot <- venn.diagram(
  x = list(
    A = A,
    D = D,
    B = B,
    C = C
  ),
  filename = NULL,
  col = "transparent",
  fill = c("cornflowerblue", "green", "yellow", "darkorchid1"),
  alpha = 0.50,
  label.col = c("orange", "white", "darkorchid4", "white", 
                "white", "white", "white", "white", "darkblue", "white", 
                "white", "white", "white", "darkgreen", "white"),
  cex = 1.5,
  fontfamily = "serif",
  fontface = "bold",
  cat.col = c("darkblue", "darkgreen", "orange", "darkorchid4"),
  cat.cex = 1.5,
  cat.pos = 0,
  cat.dist = 0.07,
  cat.fontfamily = "serif",
  rotation.degree = 270,
  margin = 0.2
);
grid.draw(venn.plot)
dev.off()
overlap <- calculate.overlap(x = list("A1" = A,"B1" = B, "C1" = C, "D1" = D))
write.table(overlap$a6,file="venn.txt",quote=F,sep = '\t', row.names = F)