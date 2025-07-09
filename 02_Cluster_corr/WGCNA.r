library(WGCNA)
library(reshape2)
library(stringr)

expr0 <- read.table("RPKM_mean.txt",sep="\t",header=1,row.names = 1)
#dim(expr0)
#head(expr0)[,1:8]
expr0 <- t(expr0)
#dim(expr0)
#head(expr0)[,1:8]
gsg <- goodSamplesGenes(expr0,verbose = 3,minNSamples = 3)
gsg$allOK
if (!gsg$allOK){
  # Optionally, print the gene and sample names that were removed:
  if (sum(!gsg$goodGenes)>0)
    printFlush(paste("Removing genes:", paste(names(expr0)[!gsg$goodGenes], collapse = ", ")));
  if (sum(!gsg$goodSamples)>0)
    printFlush(paste("Removing samples:", paste(rownames(expr0)[!gsg$goodSamples], collapse = ", ")));
  # Remove the offending genes and samples from the data:
  expr0 <- expr0[gsg$goodSamples, gsg$goodGenes]
}
power <- c(1:20)
sft <- pickSoftThreshold(expr0,powerVector = power,verbose = 5)
par(mfrow <- c(1,2))
cex1 <- 0.9
sizeGrWindow(8,8)
plot(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     xlab = "Soft Threshold (power)",
     ylab = "Scale Free Topology Model Fit,signed R^2",type="n",
     main = paste("Scale independence"))
text(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     labels = power,cex = cex1,col = "red")
abline(h = 0.85,col = "red")
plot(sft$fitIndices[,1], sft$fitIndices[,5],
     xlab = "Soft Threshold (power)",ylab = "Mean Connectivity", type="n",
     main = paste("Mean connectivity"))
text(sft$fitIndices[,1], sft$fitIndices[,5], labels=power, 
     cex = cex1, col = "red")

sampleTree = hclust(dist(expr0), method = "average");
# Plot the sample tree: Open a graphic output window of size 12 by 9 inches
sizeGrWindow(68,9)
plot(sampleTree, main = "Sample clustering to detect outliers", sub="", xlab="", cex.lab = 1.5, cex.axis = 1.5, cex.main = 2)
dev.off()

adjacency <- adjacency(expr0, power = softpower)

TOM <- TOMsimilarity(adjacency)
dissTOM <- 1-TOM

geneTree <- hclust(as.dist(dissTOM),method = "average")

sizeGrWindow(12,9)
plot(geneTree,xlab = "",sub = "",main = "gene clustering on TOM-based dissimilarity",labels = FALSE,hang = 0.04)

minModuleSize <- 30;##ordinary20-30

dynamicMods <- cutreeDynamic(dendro = geneTree,distM = dissTOM,deepSplit = 2,
                             pamRespectsDendro = FALSE,minClusterSize = minModuleSize) ###minClusterSize=minModuleSize
table(dynamicMods)
dynamicColors <- labels2colors(dynamicMods)
table(dynamicColors)
sizeGrWindow(8,6)
plotDendroAndColors(geneTree,dynamicColors,"dynamic Tree Cut",dendroLabels = FALSE,hang=0.03
                    ,addGuide = TRUE,guideHang = 0.05,main= "Gene dendrogram and module colors")

MEList <- moduleEigengenes(expr0,colors <- dynamicColors)
MEs <- MEList$eigengenes
#Calculate dissimilarity of module eigengenes 
MEDiss <- 1-cor(MEs)
#Cluster module eigengenes
MEtree <- hclust(as.dist(MEDiss),method = "average")
sizeGrWindow(7,6)
plot(MEtree,main = "Cluster of Module eigengenes",xlab = "",sub = "",hang = 0.04)
MEDissThres <- 0.25; #important threshold value
abline(h = MEDissThres,col = "red") #plot the cut line into the dendrogram
#Call an automatic merging function
merge <- mergeCloseModules(expr0,dynamicColors,cutHeight = MEDissThres,verbose = 3)
#The merged module colors
mergedColors <- merge$colors
mergedMEs <- merge$newMEs
sizeGrWindow(12,9)
plotDendroAndColors(geneTree,cbind(dynamicColors,mergedColors),c("dynamic tree cut","mergedcolors"
                                                                 ),dendroLabels = FALSE,hang = 0.03,addGuide = TRUE
                    ,guideHang = 0.05);
moduleColors <- mergedColors
#construct numberical labels corresponding to the colors;
colorOrder <- c("grey",standardColors(50))
moduleLabels <- match(moduleColors,colorOrder)-1
MEs <- mergedMEs

MEs_col <- MEs
MEs_col <- orderMEs(MEs_col)
plotEigengeneNetworks(MEs_col, "Eigengene adjacency heatmap", 
                      marDendro = c(3,3,2,4),
                      marHeatmap = c(3,4,2,2), plotDendrograms = T, 
                      xLabelsAngle = 90)
plotTOM <- dissTOM^7
#Set diagonal to NA for a nicer plot
diag(plotTOM) <- NA
sizeGrWindow(20,20)
TOMplot(plotTOM, geneTree, moduleColors, main = "Network heatmap plot, all genes")
nSelect = 400
#For reproducibility, we set the random seed
set.seed(10)
nSamples <- nrow(expr0)
nGenes <- ncol(expr0)
select <- sample(nGenes, size = nSelect)
selectTOM <- dissTOM[select, select]
selectTree <- hclust(as.dist(selectTOM),method = "average")
selectColors <- moduleColors[select]
#Open a graphical window
sizeGrWindow(9,9)
#Taking the dissimilarity to a power, say 10, makes the plot more informative by effectively changing the color palette; 
#setting the diagonal to NA also improves the clarity of the plot
plotDiss <- selectTOM^7
diag(plotDiss) <- NA
TOMplot(plotDiss, selectTree, selectColors, main = "Network heatmap plot, selected genes")

trait <- read.table("trait.txt",sep = "\t",header = 1,row.names = 1)
MEs_colpheno <- orderMEs(cbind(MEs_col, trait))
sizeGrWindow(5, 10)
plotEigengeneNetworks(MEs_colpheno, "Trait Eigengene adjacency heatmap", 
                      marDendro = c(3,3,2,4),
                      marHeatmap = c(3,4,2,2), plotDendrograms = T, 
                      xLabelsAngle = 90)
# Re-cluster samples
sampleTree <- hclust(dist(trait), method = "average")
# Convert traits to a color representation: white means low, red means high, grey means missing entry
traitColors <- numbers2colors(trait, signed = FALSE);
# Plot the sample dendrogram and the colors underneath.
plotDendroAndColors(sampleTree, traitColors,groupLabels = names(trait),main = "Sample dendrogram and trait heatmap")
nGenes <- ncol(expr0)
nSamples <- nrow(expr0)
MEs0 <- moduleEigengenes(expr0, moduleColors)$eigengenes
MEs2 <- orderMEs(MEs0)
moduleTraitCor <- cor(MEs2, trait, use = "p")
moduleTraitPvalue <- corPvalueStudent(moduleTraitCor, nSamples)
names(MEs2)
textMatrix <- paste(signif(moduleTraitCor, 2), "\n(",signif(moduleTraitPvalue, 1), ")", sep = "");
dim(textMatrix) <- dim(moduleTraitCor)
par(mar = c(6, 8.5, 3, 3))
#Display the correlation values within a heatmap plot
sizeGrWindow(10,10)
class(moduleTraitCor)
moduleTraitCor_t <- t(moduleTraitCor)
class(textMatrix)
textMatrix_t <- t(textMatrix)
labeledHeatmap(Matrix = moduleTraitCor_t,yLabels = names(trait),xLabels = names(MEs2),xSymbols = names(MEs2),
               colorLabels = FALSE,colors = greenWhiteRed(50),textMatrix = textMatrix_t,setStdMargins = FALSE,
               cex.text = 1,
               zlim = c(-1,1),
               main = paste("Module-trait relationships"))
write.table(moduleTraitCor,file="module-TraitCor.txt",quote = F)
write.table(moduleTraitPvalue,file="module-TraitPvalue.txt",quote = F)
GC.De.14 <- as.data.frame(trait$GC.De.14)
names(GC.De.14) <- "GC.De.14"
geneModuleMembership <- as.data.frame(cor(expr0, MEs2, use = "p"))
modNames <- substring(names(MEs2), 3)
geneModuleMembership <- as.data.frame(cor(expr0, MEs2, use = "p"))
MMPvalue <- as.data.frame(corPvalueStudent(as.matrix(geneModuleMembership), nSamples))
names(geneModuleMembership) = paste("MM", modNames, sep="")
names(MMPvalue) <- paste("p.MM", modNames, sep="")
geneTraitSignificance <- as.data.frame(cor(expr0, GC.De.14, use = "p"))
GSPvalue <- as.data.frame(corPvalueStudent(as.matrix(geneTraitSignificance), nSamples))
names(geneTraitSignificance) = paste("GS.De.", names(GC.De.14), sep="")
names(GSPvalue) = paste("p.GS.De", names(GC.De.14), sep="")
write.table(geneTraitSignificance,file="geneTraitSignificance_GC.De.14.txt",quote = F)
write.table(GSPvalue,file="GSPvalue_GC.De.14.txt",quote = F)
module <- "cyan"
column <- match(module, modNames)
moduleGenes <- moduleColors==module
sizeGrWindow(7, 7)
par(mfrow = c(1,1))
verboseScatterplot(abs(geneModuleMembership[moduleGenes, column]),
                   abs(geneTraitSignificance[moduleGenes, 1]),
                   xlab = paste("Module Membership in", module, "module"),
                   ylab = "Gene significance for Cotinine ",
                   main = paste("Module membership vs. gene significance\n"),
                   cex.main = 1.2, cex.lab = 1.2, cex.axis = 1.2, col = module)
cyan_module <- as.data.frame(dimnames(data.frame(expr0))[[2]][moduleGenes])
names(cyan_module) <- "genename"
write.table(cyan_module, file="cyan_gene_ID.txt",quote = F, 
            row.names = F, sep = '\t')
MM <- abs(geneModuleMembership[moduleGenes,column])
GS <- abs(geneTraitSignificance[moduleGenes, 1])
cyan_MMGS <- as.data.frame(cbind(MM,GS))
rownames(cyan_MMGS) <- cyan_module$genename
dim(cyan_MMGS)
hub <- abs(cyan_MMGS$MM)>0.7&abs(cyan_MMGS$GS)>0.5
table(hub)
cyan_hub<-subset(cyan_MMGS, abs(cyan_MMGS$MM)>0.7&abs(cyan_MMGS$GS)>0.5)

write.table(cyan_hub, file = "hubgene_MMGS_cyan_GC.De.14.txt", 
            quote = F, row.names = T, sep = '\t')


RPKM <- data.frame(read.table('RPKM_mean.txt', header=1))
rownames(RPKM) <- RPKM$t_name  
head(RPKM)
RPKM['evm.model.Contig1.18',]
probes_hub <- data.frame(rownames(cyan_hub))
names(probes_hub) <- "gene_ID"
head(probes_hub)
dim(probes_hub)[1]
probes_hub <- as.vector(probes_hub)
probes_hub <- probes_hub$gene_ID
head(probes_hub)
hubgene_expr0 <- RPKM[RPKM$t_name %in% probes_hub,]
hubgene_expr0 <- hubgene_expr0[,-1]
hubgene_expr0 <- t(hubgene_expr0)
head(hubgene_expr0)  
dim(hubgene_expr0)
TOMcyt_hub <- TOMsimilarityFromExpr(hubgene_expr0, power = softpower, weights = NULL,
                                corType = "pearson", networkType = "unsigned")
cyt <- exportNetworkToCytoscape(TOMcyt_hub,
                                edgeFile = paste("Cytoscape_edges_", paste(modules, collapse="-"), ".txt", sep=""),
                                nodeFile = paste("Cytoscape_nodes_", paste(modules, collapse="-"), ".txt", sep=""),
                                weighted = T,
                                threshold = 0.2,
                                nodeNames = probes_hub,
                                #nodeAttr = moduleColors[inModule]
                                )
Anno <- data.frame(read.csv('Annotation_Summary.txt',header=1, sep = '\t'))
dim(Anno)
head(Anno)
rownames(Anno) <- Anno$gene_id
Anno['evm.model.LG04.2744',]
hub_Anno <- Anno[Anno$gene_id %in% probes_hub,]
head(hub_Anno)
dim(hub_Anno)
write.table(hub_Anno, file="hub_Anno_cyan_GC.De.14.txt", quote = F, col.names = F, sep = '\t')
probes_hub <- as.vector(probes_hub)
probes_hub <- probes_hub$gene_ID
head(probes_hub)
cyan_Anno <- Anno[Anno$gene_id %in% cyan_module$genename,]
write.table(cyan_Anno, file="Anno_cyan.txt", quote = F, col.names = F, sep = '\t')

ls()
TOMcyt <- TOMsimilarityFromExpr(expr0, power = softpower, weights = NULL,
                                corType = "pearson", networkType = "unsigned")
TOMcyt[1:6,1:6]

#annot <- read.csv(file = "GeneAnnotation.csv",row.names = 1)

modules <- "cyan"

probes <- names(expr0)
head(probes,3)

inModule <- (moduleColors==modules)
inModule <- is.finite(match(moduleColors, modules))
head(inModule,6)
modProbes <- probes[inModule]
head(modProbes,3)

modTOM <- TOMcyt[inModule, inModule]
dim(modTOM)
modTOM[1:6,1:6]

dimnames(modTOM) <- list(modProbes, modProbes)
modTOM[1:6,1:6]

nTop <- 30

IMConn <- softConnectivity(expr0[, modProbes])
head(IMConn)

top <- (rank(-IMConn) <= nTop)
head(top)
topmodTOM <- modTOM[top, top]
dim(topmodTOM)
topmodTOM[1:30,]
topmodProbes <- modProbes[top]
head(topmodProbes)

write.table(modTOM, file = "cyan_cor.txt",quote = F,sep = '\t')

cyt <- exportNetworkToCytoscape(TOMcyt,
                                edgeFile = paste("Cytoscape_edges_", paste(modules, collapse="-"), ".txt", sep=""),
                                nodeFile = paste("Cytoscape_nodes_", paste(modules, collapse="-"), ".txt", sep=""),
                                weighted = TRUE,
                                threshold = 0.2,
                                nodeNames = modProbes,
                                nodeAttr = moduleColors[inModule])

cyttop30 <- exportNetworkToCytoscape(topmodTOM,
                                edgeFile = paste("Cytoscape_edges_", paste(modules, collapse="-"), "_top30.txt", sep=""),
                                nodeFile = paste("Cytoscape_nodes_", paste(modules, collapse="-"), "_top30.txt", sep=""),
                                weighted = TRUE,
                                threshold = 0.02,
                                nodeNames = topmodProbes,
                                nodeAttr = modules
                                )

Cytoscape_edges_darkseagreen4 <- read.table("Cytoscape_edges_darkseagreen4.txt", header = T)
head(Cytoscape_edges_darkseagreen4)
dim(Cytoscape_edges_darkseagreen4)
Cytoscape_edges_darkseagreen4_selected <- Cytoscape_edges_darkseagreen4[which(Cytoscape_edges_darkseagreen4$weight > 0.43), ]
head(Cytoscape_edges_darkseagreen4_selected)
dim(Cytoscape_edges_darkseagreen4_selected)
write.table(Cytoscape_edges_darkseagreen4_selected, file = "Cytoscape_edges_darkseagreen4_selected.txt",quote = F)