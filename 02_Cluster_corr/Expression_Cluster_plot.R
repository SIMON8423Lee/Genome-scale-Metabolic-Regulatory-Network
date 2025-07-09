library(ggplot2)
#library(pheatmap)
library(reshape2)
newOrder <- read.table("Gene_Cluster.txt",header = T, row.names = 1,check.names = F)

data_new <- melt(newOrder)

data_new$value[data_new$value>4]=4 
data_new$value[data_new$value< -4]= -4 

p1 <- ggplot(data_new,aes(variable, value, group=Gene)) + geom_line(color="#f6f4d2",size=0.8) + 
  geom_hline(yintercept =0,linetype=2) +
  stat_summary(aes(group=1),fun.y=mean, geom="line", size=1.2, color="#fdc500") + 
  facet_wrap(Cluster~.) +
  theme_bw() + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        axis.text = element_text(size=8, face = "bold"),
        strip.text = element_text(size = 8, face = "bold"))
p1

newOrder <- read.table("Meta_Cluster.txt",header = T, row.names = 1,check.names = F)

data_new <- melt(newOrder)

data_new$value[data_new$value>4]=4 
data_new$value[data_new$value< -4]= -4 

p2 <- ggplot(data_new,aes(variable, value, group=Meta)) + geom_line(color="#42a5f5",size=0.8) + 
  geom_hline(yintercept =0,linetype=2) +
  stat_summary(aes(group=1),fun.y=mean, geom="line", size=1.2, color="#0d47a1") + 
  facet_wrap(Cluster~.) +
  theme_bw() + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        axis.text = element_text(size=8, face = "bold"),
        strip.text = element_text(size = 8, face = "bold"))
p2
