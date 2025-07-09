library(tidyverse)
library(ggrepel)
library(ggfun)
library(grid)
library(ggplot2)
dataset <- read.table('vocano_plot_input.txt',header = TRUE)
cut_off_pvalue = 0.001
cut_off_logFC = 1
dataset$change = ifelse(dataset$pValue < cut_off_pvalue & abs(dataset$log2FC) >= cut_off_logFC, 
                        ifelse(dataset$log2FC> cut_off_logFC ,'Up','Down'),
                        'Stable')
ggplot(dataset, aes(x = log2FC, y = -log10(pValue), colour = change)) +
  geom_point(alpha = 0.85, size = 1.5) +  
  scale_color_manual(values = c('steelblue', 'gray', 'brown')) +  
  xlim(c(-10, 10)) +  
  geom_vline(xintercept = c(-1, 1), lty = 4, col = "black", lwd = 0.8) +  
  theme_bw() +
  geom_hline(yintercept = -log10(0.001), lty = 4, col = "black", lwd = 0.8) +  
  labs(x = "log2FC", y = "-log10FDR") +  
  ggtitle("NtERF167-OE VS WT") + 
 # theme(plot.title = element_text(hjust = 0.5), legend.position = "right", legend.title = element_blank()) +  
  geom_label_repel(data = dataset, aes(label = label),  
                   size = 3, box.padding = unit(0.5, "lines"),
                   point.padding = unit(0.8, "lines"),
                   segment.color = "black",
                   show.legend = FALSE, max.overlaps = 10000)   