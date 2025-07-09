library("Mfuzz")
library("marray")
gene <- read.table("RPKM.txt",header =T,row.names=1,sep="\t")
head(gene)
dim(gene)
dt2 <- log(gene+1)
n=t(scale(t(dt2)))
n[n>4]=4 
n[n< -4]= -4
n <- as.matrix(n)

gene <- read.table("RPKM.txt",header =T,row.names=1,sep="\t")

gene.m <- data.matrix(gene)
gene.n <- new("ExpressionSet",exprs = gene.m)

gene.f <- filter.NA(gene.n, thres=0.25)

gene.i <- fill.NA(gene.f,mode="mean")

gene.o <- filter.std(gene.i,min.std=0.1,visu = T)

gene.s <- standardise(gene.o)

m <- mestimate(gene.s) # 计算平滑因子m的值

#tmp <-cselection(gene.s,m=1.56,crange=seq(5,40,5),repeats=5,visu=TRUE)

cl <- mfuzz(gene.s, c=9, m=m)

mfuzz.plot2(gene.s,cl=cl,mfrow= c(3,3),time.labels = c(paste(seq(20,66,2),"")),ax.col="black",bg = "white",
            col.main="black",col.sub="blue",col="blue",cex.main=4, cex.lab =3, cex.axis =2, min.mem = 0.5,
            xlab = "DAT",ylab = "Expression changes",x11=FALSE,
            centre.col="#e3ffb9",centre.lwd=4,centre=T,
            Xwidth=150, Xheight=100)

write.table(cl$cluster,"meta_gene_Mfuzz.txt",quote=F,row.names=T,col.names=F,sep="\t")
