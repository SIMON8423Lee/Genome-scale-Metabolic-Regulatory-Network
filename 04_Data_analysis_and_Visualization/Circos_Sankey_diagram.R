library(sankeywheel)
library(ggplot2)
library(highcharter)
library(tidyverse)

df <- read.table('Network.txt', sep = '\t', header = T)
highchart()%>%
  hc_add_series(data = df,
                type = "dependencywheel",
                hcaes(from = from,to = to,weight = num))%>%
  hc_add_theme(hc_theme_sandsignika())