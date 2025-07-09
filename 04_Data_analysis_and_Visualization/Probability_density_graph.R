library(ggplot2)
library(ggthemes)
pcc <- read.table('PCC_dentisy_input.txt', sep = '\t',header = T)
ggplot(pcc,aes(x=Value,colour = Group))+geom_density()+theme_classic() +
  scale_colour_manual(values = c("#008B8B", "#5E4FA2")) +
  theme(
    panel.border = element_rect(color = "black", linewidth = 1, fill = NA), 
    legend.title = element_blank(),
    legend.position = "none"
    )