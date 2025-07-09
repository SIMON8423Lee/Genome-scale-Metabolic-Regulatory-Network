library(ggplot2)
library(ggpubr)
library(ggpmisc)
theme_set(ggpubr::theme_pubr()+
            theme(legend.position = "top"))
# Load data
gene <- read.table(file = "gene_count_changeID.txt", header=T, row.names = 1, sep = '\t')
dt2 <- log(gene)
p12 <- ggplot(dt2) +
  geom_point(aes(x = G70, y = G71, color = "R1 vs R2")) +  
  geom_smooth(aes(x = G70, y = G71, color ="R1 vs R2"), method = "lm", se = FALSE, fullrange = TRUE) +  
  #geom_rug(aes(color = "R1 vs R2")) +   
  ggpubr::stat_cor(aes(x = G70, y = G71, color = "R1 vs R2"), label.y = 12, cor.coef.name = "R") + 
  geom_point(aes(x = G70, y = G72, color = "R1 vs R3")) +  
  geom_smooth(aes(x = G70, y = G72, color ="R1 vs R3"), method = "lm", se = FALSE, fullrange = TRUE) +  
  #geom_rug(aes(color = "R1 vs R3")) +
  ggpubr::stat_cor(aes(x = G70, y = G72, color = "R1 vs R3"), label.y = 11, cor.coef.name = "R") + 
  geom_point(aes(x = G71, y = G72, color = "R2 vs R3")) +  
  geom_smooth(aes(x = G71, y = G72, color ="R2 vs R3"), method = "lm", se = FALSE, fullrange = TRUE) +  
  #geom_rug(aes(color = "R2 vs R3")) +
  ggpubr::stat_cor(aes(x = G71, y = G72, color = "R2 vs R3"), label.y = 10, cor.coef.name = "R") +
  scale_color_manual(values = c("#16EF93", "#A11FF3", "#FFA726"))+ 
  labs(title = "DBH26") +#, x = "Normalized read counts (log value)", y = "Normalized read counts (log value)", color = "Group") +
  theme(panel.border = element_rect(fill=NA, color="black", size=1, linetype="solid")) + 
  #theme(legend.position = c(0.8,0.3)) +  
  xlab(NULL)+
  ylab(NULL)+  
  theme(legend.position="none")+ 
  theme(plot.title = element_text(hjust = 0.5)) 