library(ggplot2)
library(forcats)
library(reshape2)
require(scales)
library(aplot)
library(dplyr)
go_enrich_df <- read.csv(file = "./go_enrichment_input.txt", header = 1, sep = '\t')
go_enrich_df$type_order <- factor(rev(as.integer(rownames(go_enrich_df))),labels=rev(go_enrich_df$Description))
go_enrich_df$fold <- -log(as.numeric(go_enrich_df$GeneRatio))
go_enrich_df$LOGP <- ''
go_enrich_df$LOGP <- -log(as.numeric(go_enrich_df$p.adjust))
COLS <- c("#008B8B", "#5E4FA2", "#FFA745")
p1 <- ggplot(data=go_enrich_df, aes(x=type_order,y=LOGP, fill=Class)) + 
  geom_bar(stat="identity", width=0.8) + 
  scale_fill_manual(values = COLS) + 
  coord_flip() + 
  xlab("GO term") + 
  ylab("Gene_Number") + 
  labs(title = "The Most Enriched GO Terms")+
  theme_bw()

######################################################
p2 <- ggplot(go_enrich_df, aes(x=type_order,y=fold)) +
  geom_bar(aes(fill=LOGP), stat="identity", width=0.8) + 
  #labs(y = 'Gene Number', fill = '') +
  scale_fill_gradient(low = "#00509d",high = "#ffd500")+
  #scale_y_continuous(limits = c(minimum, maximum), breaks = seq(minimum, maximum, nbreaks)) +
  #scale_fill_manual(values = COLS) + 
  coord_flip() + 
  xlab("KEGG term") + 
  ylab("CompoundRatio") + 
  #labs(title = "The Most Enriched GO Terms")+
  theme_bw()

cluster <- go_enrich_df$Description %>% as.data.frame() %>%
  mutate(group=rep(c("CC","MF","BP"),
                   times=c(11,3,25))) %>%
  mutate(p="")%>%
  ggplot(aes(p,.,fill=group))+
  geom_tile() + 
  scale_y_discrete(position="right") +
  theme_minimal()+xlab(NULL) + ylab(NULL) +
  theme(axis.text.y = element_blank(),
        axis.text.x =element_text(
          angle =90,hjust =0.5,vjust = 0.5))+
  labs(fill = " ")

p2%>%
  insert_right(cluster, width = .1)

kegg_enrich_df <- read.csv(file = "KEGG_enrichment_input.txt", header = 1, sep = '\t')
kegg_enrich_df$type_order <- factor(rev(as.integer(rownames(kegg_enrich_df))),
                                  labels=rev(kegg_enrich_df$Description))
kegg_enrich_df$fold <- ''
kegg_enrich_df$fold <- -log(as.numeric(kegg_enrich_df$GeneRatio))
kegg_enrich_df$LOGP <- ''
kegg_enrich_df$LOGP <- -log(as.numeric(kegg_enrich_df$p.adjust))

p3 <- ggplot(kegg_enrich_df, aes(CompoundRatio, type_order)) +
  geom_point(aes(color=fold, size=LOGP))+theme_bw()+
  theme(panel.grid = element_blank(),
        axis.text.x=element_text(angle=90,hjust = 1,vjust=0.5))+
  scale_color_gradient(low = "#13315c",high = "#f77f00")+
  labs(y="KEGG term",x="CompoundRatio")+guides(size=guide_legend(order=3))+
  theme(legend.direction = "horizontal", legend.position = "top")+
  scale_y_discrete(position = "left")