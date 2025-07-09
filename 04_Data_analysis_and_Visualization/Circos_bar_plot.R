library(tidyverse)
library(ggplot2)
df <- read.table(file = "TF_Target_PCC.txt",header = T,sep = '\t',check.names = F) 
empty_bar <- 4
to_add <- data.frame( matrix(NA, empty_bar*nlevels(df$Group), ncol(df)) )
colnames(to_add) <- colnames(df)
to_add$Group <- rep(levels(df$Group), each=empty_bar)
df <- rbind(df, to_add)
df <- df %>% arrange(Group)
df$id <- seq(1, nrow(df))
label_df <- df
number_of_bar <- nrow(label_df)
angle <- 90 - 360 * (label_df$id-0.5) /number_of_bar     
label_df$hjust <- ifelse( angle < -90, 1, 0)
label_df$angle <- ifelse(angle < -90, angle+180, angle)

ggplot(df, aes(x=as.factor(id), y=PCC, fill=Group)) + # Note that id is a factor. If x is numeric, there is some space between the first bar
  geom_bar(stat="identity", alpha=0.7) +  
  ylim(-60,100) +
  geom_errorbar(aes(ymin=PCC-0.1*PCC,ymax=PCC+0.1*PCC,width=0.1),position = position_dodge(width=0.9)) + 
  theme_minimal() +
  theme(
    legend.position = "top",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(-1,4), "cm") 
  ) +
  scale_fill_manual(values = c("#138BB9", "#EA4545","#FFA745","#008B8B","#3D5387","#6FCCA2","#5E4FA2")) +
  geom_hline(yintercept = 23.6, colour='#3D5387') +
  coord_polar() + 
  geom_text(data=label_df, aes(x=id, y=PCC+20, label=TF, hjust=hjust), color="black", 
            fontface="bold",alpha=0.6, size=2.5, angle= label_df$angle, inherit.aes = FALSE ) 

