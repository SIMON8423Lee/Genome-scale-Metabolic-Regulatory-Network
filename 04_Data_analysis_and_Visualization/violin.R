library(ggplot2)
library(plyr)
library(reshape2)
data <- read.table('input.txt',header = T,sep = '\t')
data1 <- melt(data)
ggplot(data=data1, aes(x=variable, y=value, fill=Attribute)) + 
  geom_split_violin(trim=TRUE,color='white') +
  #geom_point(data = Data_summary,aes(x=Group, y=value),pch=19,position=position_dodge(0.9),size=1.5)+ 
  #geom_errorbar(data = Data_summary,aes(ymin = value-ci, ymax=value+ci), 
  #              width=0.1, 
  #              position=position_dodge(0.9), 
  #              color="black",
  #              alpha = 0.7,
  #              size=0.5) +
  scale_fill_manual(values = c("#3D5387", "#6FCCA2"))+ 
  theme_bw()+ 
  theme(axis.text.x=element_text(angle=15,hjust = 1,colour="black",family="Times",size=4), 
        axis.text.y=element_text(family="Times",size=4,face="plain"), 
        axis.title.y=element_text(family="Times",size = 4,face="plain"), 
        panel.border = element_blank(),axis.line = element_line(colour = "black",size=1),
        legend.text=element_text(face="italic", family="Times", colour="black",  
                                 size=4),
        legend.title=element_text(face="italic", family="Times", colour="black", 
                                  size=4),
        legend.position = 'none',
        panel.grid.major = element_blank(),  
        panel.grid.minor = element_blank())+  
    ylab("Value")+xlab("") 