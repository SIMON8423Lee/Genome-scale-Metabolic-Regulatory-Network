library(UpSetR)
library(ggplot2)
library(plyr)
library(gridExtra)
library(grid)
meta <- read.csv(file = "input.txt", header = TRUE, sep="\t")
upset(meta, nsets = 4, 
      nintersects = 30, 
      mb.ratio = c(0.7, 0.3), 
      order.by = "freq", 
      decreasing = c(TRUE,FALSE))