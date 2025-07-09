library(multcomp)
library(fdrtool)
library(ggplot2)
library(forcats)
library(reshape2)
require(scales)
library(aplot)
library(dplyr)
dt <- read.table(file = "Cluster_TF_hypergeometric_test_input.txt", header = T, sep = '\t')
## output res and P
res=list() ##total res
plist=list() ## total P values
for (i in 1:dim(dt)[1]){
  a <- dt[i,6]
  b <- dt[i,5]
  c <- dt[i,4]
  d <- dt[i,3]
  fit=phyper(a-1, c, d-c, b, lower.tail = F)
  idx=i
  res[idx]=summary(fit)
  print(idx)
  # save P value
  pres=matrix(unlist(res[[idx]]),1)[,1][1]
  pdata=as.data.frame(t(pres))
  colnames(pdata)=("p")
  plist[[idx]]=pdata
}

totalp <- do.call(rbind,plist)
fdr <- fdrtool(totalp[,1],statistic="pvalue")
finaldata <- cbind(totalp,fdr$qval)
colnames(finaldata) <- c("p","FDR")
head(finaldata)
data <- cbind(dt,finaldata)
head(data)
data$type_order <- factor(rev(as.integer(rownames(data))),
                                    labels=rev(data$Class))
data$fold <- ''
data$fold <- -log(as.numeric(data$ClassRatio))
data$LOGP <- ''
data$LOGP <- -log(as.numeric(data$FDR))
p2 <- ggplot(data, aes(Group, type_order)) +
  geom_point(aes(color=LOGP, size=fold))+theme_bw()+
  theme(axis.text.x=element_text(angle=90,hjust = 1,vjust=0.5))+
  scale_color_gradient(low='#386CB0',high='#FF7F00')+
  labs(x=NULL,y=NULL)+guides(size=guide_legend(order=3))+
  theme(legend.direction = "horizontal", legend.position = "top")+
  scale_y_discrete(position = "right")
write.table(data, file = "Cluster_TF_hypergeometric_test.txt", quote = F, sep = '\t', row.names = F)