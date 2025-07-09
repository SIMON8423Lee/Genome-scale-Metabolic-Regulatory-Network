library(Hmisc)
library(reshape2)

for (i in 1:4){
  SG <- read.csv(paste0("SG_Rep",i,".txt"),row.names = 1, sep = '\t', header = T, check.names = F)
  TF <- read.csv(paste0("TF_Rep",i,".txt"),row.names = 1, sep = '\t', header = T, check.names = F)
  metabolite <- read.csv(paste0("meta_Rep",i,".txt"),row.names = 1, sep = '\t', header = T, check.names = F)
  SG <- t(SG)
  TF <- t(TF)
  metabolite <- t(metabolite)
 
  R_corr_pearson1 <- rcorr(as.matrix(SG),as.matrix(TF), type = 'pearson')
  R_corr_pearson2 <- rcorr(as.matrix(SG),as.matrix(metabolite), type = 'pearson')
  R_corr_pearson3 <- rcorr(as.matrix(TF),as.matrix(metabolite), type = 'pearson')

  SGTF_r <- melt(R_corr_pearson1$r)
  SGME_r <- melt(R_corr_pearson2$r)
  TFME_r <- melt(R_corr_pearson3$r)
  SGTF_p <- melt(R_corr_pearson1$P)
  SGME_p <- melt(R_corr_pearson2$P)
  TFME_p <- melt(R_corr_pearson3$P)
  SGTF <- cbind(SGTF_r, SGTF_p)
  SGTF <- SGTF[,-5]
  SGTF <- SGTF[,-4]
  names(SGTF) <- c("fromnode", "tonode", "r", "P")
  SGME <- cbind(SGME_r,SGME_p)
  SGME <- SGME[,-5]
  SGME <- SGME[,-4]
  names(SGME) <- c("fromnode", "tonode", "r", "P")
  TFME <- cbind(TFME_r, TFME_p)
  TFME <- TFME[,-5]
  TFME <- TFME[,-4]
  names(TFME) <- c("fromnode", "tonode", "r", "P")

  

  write.table(SGTF, file = paste0("R_corr_pearsonSG_TF_",i,".txt"), quote = F, row.names = F, sep = '\t')
  write.table(SGME, file = paste0("R_corr_pearsonSG_ME_",i,".txt"), quote = F, row.names = F, sep = '\t')
  write.table(TFME, file = paste0("R_corr_pearsonTF_ME_",i,".txt"), quote = F, row.names = F, sep = '\t')
}


