library(tidyverse)
library(readr)
library(ggplot2)
library(ggalluvial)
library(latex2exp)
data <- read.table('PCC_kmeans.txt', sep = '\t', header = T)
ggplot(data=data,
       aes(axis1=kmeans,axis2=PCC,
           y=Gene))+
  geom_alluvium(aes(fill=kmeans,color=kmeans),
                size=0.7,
                alpha=0.6,
                curve_type = "cubic", 
                show.legend = FALSE,
                width = 1/4,
                aes.bind = "flows")+
  geom_stratum(fill=c("#238B45","#696969","#5E4FA2",'#6FCCA2','#3D5387',"#008B8B","#FFA745","#EA4545","#138BB9",
                      "#238B45","#696969","#5E4FA2",'#6FCCA2','#3D5387',"#008B8B","#FFA745","#EA4545","#138BB9"),
               color=c("#238B45","#696969","#5E4FA2",'#6FCCA2','#3D5387',"#008B8B","#FFA745","#EA4545","#138BB9",
                       "#238B45","#696969","#5E4FA2",'#6FCCA2','#3D5387',"#008B8B","#FFA745","#EA4545","#138BB9"),
               alpha = 1,
               #size=0.1,
               show.legend = FALSE,
               width=1/4)+
  scale_fill_manual(breaks = c('Cluster1',"Cluster2","Cluster3","Cluster4","Cluster5","Cluster6","Cluster7","Cluster8","Cluster9"),
                    values = c("#138BB9","#EA4545","#FFA745","#008B8B",'#3D5387','#6FCCA2',"#5E4FA2","#696969","#238B45"),
                    labels = c("1","2","3","4","5","6","7","8","9")) +
  scale_color_manual(breaks = c('Cluster1',"Cluster2","Cluster3","Cluster4","Cluster5","Cluster6","Cluster7","Cluster8","Cluster9"),
                     values = c("#138BB9","#EA4545","#FFA745","#008B8B",'#3D5387','#6FCCA2',"#5E4FA2","#696969","#238B45"),
                     labels = c("1","2","3","4","5","6","7","8","9")) +
  geom_label(stat = "stratum", aes(label = after_stat(stratum)))+
  scale_x_continuous(breaks = c(1,2),
                     labels = c("kmeans","PCC"),
                     expand = c(0.025,0.025))+
  #scale_y_continuous(limits = c(0,27000), breaks = seq(0, 27000, 900),
  #                   expand = c(0,0)) +
  theme_classic() +
  theme(panel.grid = element_blank(),
        axis.title = element_blank(),
        axis.text = element_text (size = 10, 
                                  family = "sans"),
        plot.margin = unit(c(0,1.5,0,0),'cm'))+
  coord_cartesian(clip="off")