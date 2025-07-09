library(ComplexHeatmap)
library(circlize)
library(magick)
dt <- read.table("./Cluster9_all.txt",header = T,row.names = 1,sep = '\t')
Module11 <- a %>% t() %>% as.data.frame() %>%
  rownames_to_column("sample") %>%
  gather(key = gene_symbol,
         value = value, -sample)
Module11$sample <- factor(Module11$sample, unique(Module11$sample))
p9 <- ggplot(Module11, aes(x = sample, y = value, group = gene_symbol)) +
  geom_line(color = "grey") +
  theme_no_axes()
p9
p1/p2/p3/p4/p5/p6/p7/p8/p9
a <- dt[1:1000,]