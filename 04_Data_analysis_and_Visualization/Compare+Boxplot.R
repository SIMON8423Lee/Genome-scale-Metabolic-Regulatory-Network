library(ggplot2)
library(ggpubr)
library(reshape2)
library(tableone)
library(agricolae)
dt <- read.table("R_cor_compare_input_all.txt", header = T, sep = '\t')
modelD <- aov(r ~ groups, dt)
summary(modelD)
outD <- LSD.test(modelD, "groups", p.adj = "none" ) 
outD$groups 

ggplot(dt, aes(x=groups, y=r, fill=groups)) +
  scale_fill_manual(values = c("#138BB9", "#6FCCA2","#FFA745")) +
  scale_colour_manual(values = c("#138BB9", "#6FCCA2","#FFA745")) +
#  scale_x_continuous(c(1,1,1)) +
 # annotate("text", x = 1, y = 1.1, size = 10, label = "a") + # 加文字
  #annotate("text", x = 2, y = 0.95, size = 10, label = "b") + # 加文字
  #annotate("text", x = 3, y = 0.95, size = 10, label = "b") + # 加文字
  theme_classic() +
  theme( legend.position = "none") +
  geom_boxplot()

