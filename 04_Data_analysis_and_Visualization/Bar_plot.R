dt1 <- read.table("input.txt", header = T, sep = '\t')
head(dt1)
dt1$Group <- factor(dt1$Group, levels = c("Empty", "NtDREB3"))
library(tableone)
library(agricolae)
library(ggplot2)
modelD <- aov(Value ~ Group, dt1)
summary(modelD)
outD <- LSD.test(modelD, "Group", p.adj = "none" ) 

p <- ggplot(dt1, aes(x = Group, y = Value, fill = Group)) +
  stat_summary( 
    fun.data = "mean_se",
    geom = "bar",
    position = position_dodge(0.5),
    colour = "black",
    size = 0.3,
    width = 0.2) +
  stat_summary( 
    fun.data = "mean_se",
    colour = "black",
    geom = "errorbar",
    position = position_dodge(0.5),
    size = 0.3,
    width = 0.1) +
  geom_point( 
    pch = 1,
    size = 2.5,
    colour = "black",
    position = position_jitterdodge(0.2, 0.5, 0.5, seed = 111),
    show.legend = FALSE) +
  geom_point(
    alpha = 0.6,
    pch = 16,
    size = 2.5,
    colour = "#DEDFDE",
    position = position_jitterdodge(0.2, 0.5, 0.5, seed = 111),
    show.legend = FALSE) +
  scale_fill_manual(
    values = c("#3D5387", "#008B8B")) + 
  scale_y_continuous( 
    expand = c(0, 0),
    limits = c(0, 15),
    breaks = seq(0, 15, 5)) + 
  #scale_x_continuous( 
   # #expand = c(0, 0)) +
    #expand = expansion(mult = c(0,0))) +
    #breaks = c(0, 5, 10, 15, 20)) +
  annotate("text", x = 1.5, y = 14, size = 10, label = "***") +
  annotate("text", x = 1.5, y = 13, size = 5, label = "p=1.06e-05") + 
  annotate("segment", x = 1, xend = 2, y = 11.8, yend = 11.8, colour = "grey", size = 0.5) + 
  annotate("point", x = 1.5, y = 12.2, colour = "grey60", pch = 17, size = 5) + 
  theme_classic() + 
  theme(
    panel.border = element_rect(color = "black", size = 1, fill = NA),
    axis.line = element_line(colour = "grey30", size = 0.23), 
    axis.ticks.y = element_line(size = 0.2, colour = "grey30"),
    axis.ticks.x = element_line(size = 0.2, colour = "transparent"),
    axis.text = element_text(size = 10, colour = "black"),
    legend.title = element_blank(),
    legend.position = "top",
    legend.direction = "horizontal") +
  labs(#subtitle = "c",
       x = "",
       y = expression("Relative Luc/Ren ratio")
  )



