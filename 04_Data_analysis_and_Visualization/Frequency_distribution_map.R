library(ggplot2)
library(ggpubr)
library(plyr)
library(tidyverse)
library(ggside)
dt <- read.table('input.txt', sep = '\t', header = T)
ggplot(dt, aes(x = Nt4CL2, y = TM221, colour = Gene)) +
  geom_point() +
  scale_color_manual(values = c("#EA4545", "#FFA745"))+ 
  geom_smooth(method = "lm",colour ='#138BB9')+
  theme(panel.border = element_rect(fill=NA, color="black", linewidth=1, linetype="solid")) + 
  ggpubr::stat_cor(aes(x = Nt4CL2, y = TM221), label.y =3, cor.coef.name = "R") + 
  xlab('FPKM ')+
  ylab('CGA Content')+
  theme_bw()+
  theme(legend.position="left") 

ggplot(dt, aes(x = Nt4CL2, y = MYB28, colour = Gene)) +
  geom_point() +
  geom_smooth(method = "lm")+
  scale_color_manual(values = c("#EA4545", "#3D5387"))+  
  theme(panel.border = element_rect(fill=NA, color="black", linewidth=1, linetype="solid")) + 
  xlab('FPKM ')+
  ylab('FPKM of NtMYB28')+
  theme_bw()+
  theme(legend.position="none") 