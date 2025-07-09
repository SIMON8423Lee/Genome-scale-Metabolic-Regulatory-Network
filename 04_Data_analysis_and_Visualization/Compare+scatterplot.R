library(ggplot2)
library(ggpubr)
library(tableone)
library(agricolae)
library(gg.gap)
dt <- read.table("R_cor_compare_input.txt", header = T, sep = '\t')
p <- ggplot(dt, aes(x = groups, y = r, colour = groups)) +
  stat_summary(fun.data = "median_q1q3", geom = "errorbar", width = 0.2, size = 0.5) +
  stat_summary(aes(fill = groups), fun.y = median, geom = "crossbar", width = 0.5, size = 0.3) + 
  geom_point(size = 2.5, position = position_jitter( width = 0.15, height = 0, seed = 1026)) + 
  scale_colour_manual(values = c("#138BB9", "#EA4545","#FFA745")) +
  scale_fill_manual(values = c("#138BB9", "#EA4545","#FFA745")) +
  #geom_hline(yintercept = 10, linetype = 3, size = 1) +
  annotate("text", x = 1.5, y = 1.8, size = 20, label = "*") + 
  annotate("text", x = 1.5, y = 1.8, size = 5, label = "P=0.0255") + 
  annotate("segment", x = 1, xend = 2, y = 1.5, yend = 1.8, size = 1) + 
  annotate("segment", x = 1, xend = 1, y = 1.5, yend = 1.8, size = 1) +
  annotate("segment", x = 2, xend = 2, y = 1.5, yend = 1.8, size = 1) + 
  #scale_y_continuous(breaks = c(0, 10, 50, 100, 150, 200), limits = c(1, 200), 
  #              expand = c(0, 0), labels = c("0", "10", "50", "100", "150", "200")) +
  theme_classic() +
  theme(plot.subtitle = element_text(face = "bold", size = 16, hjust = -0.15),
        axis.line = element_line(size = 0.2),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11),
        legend.position = "none") +
  labs(subtitle = "c",
       x = "",
       #y = expression("Temperature(℃)")
       )
p2 <- gg.gap(plot = p,
            segments = c(70, 180),
            tick_width = c(5,20),
            rel_heights = c(2,0,0.5),
            ylim = c(0, 210)
)