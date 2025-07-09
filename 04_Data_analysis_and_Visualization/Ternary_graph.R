library(ggplot2)
library(ggtern)
data <- read.csv('TM_cluster_input.txt', sep='\t', header = T)
ggtern(data=data,aes(x=TF,y=SG,z=ME,
                         
                         shape=Cluster, 
                         
                         color=Cluster ) ) + 
  scale_color_manual(values = c("#138BB9", "#EA4545","#FFA745","#008B8B","#3D5387","#6FCCA2","#5E4FA2","#696969","violetred1")) +
  
  theme_rgbw( ) + 
  
  geom_point(aes(fill=Cluster), 
             
             size=2, 
             
             shape=16, 
             
            ) +
  theme_custom(           
    base_size = 12,
    base_family = "",
    tern.plot.background = NULL,
    tern.panel.background = NULL,
    col.T = "black",
    col.L = "black",
    col.R = "black",
    col.grid.minor = "white"
  ) +
  theme_legend_position("topright") 