#!/usr/bin/Rscript
library(getopt)
spec = matrix(c(
                                'help' , 'h', 0, "logical","get help",
                                'gene' , 'g', 1, "character","input expression data, required",
                                'meta' , 'm', 1, "character","metabolite data, required",
                                'prefix' , 'p', 1, "character","the output file prefix  [optional, default: result ]",
                                'outdir' , 'o', 1, "character","the output file directory [optional, default: cwd ]"
                ), byrow=TRUE, ncol=5);
opt = getopt(spec);

# define usage function
print_usage <- function(spec=NULL){
        cat(getopt(spec, usage=TRUE));
        cat("Usage example: \n")
        cat("
                                        Rscript Gene_Meta_GINI.R -g expression_data.txt -m metabolite.txt -p result -o ./
                                        \n")
        q(status=1);
}
# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) { print_usage(spec) }
if ( is.null(opt$gene) ) { print_usage(spec) }
if ( is.null(opt$meta) ) { print_usage(spec) }
if ( is.null(opt$prefix) )      { opt$prefix = "result" }
if ( is.null(opt$outdir) )      { opt$outdir = getwd() }
if( !file.exists(opt$outdir) ){
        if( !dir.create(opt$outdir, showWarnings = FALSE, recursive = TRUE) ){
                stop(paste("dir.create failed: output dir=",opt$outdir,sep=""))
        }
}

#加载程绩包
library(reldist)
library(randomForest)
library(dplyr)
library(reshape2)
library(doParallel)
library(data.table)

# 1. 加载数据
gene_data <- t(read.table(opt$gene, row.names = 1, header = T))  # 基因表达数据
#gene_data2 <- t(gene_data1) #行名为样品，列名为基因
metab_raw <- read.table(opt$meta, row.names = 1, header = TRUE)
metab_data <- as.data.frame(t(metab_raw))
colnames(metab_data) <- rownames(metab_raw)  # 确保列名正确
rownames(metab_data) <- colnames(metab_raw)  # 保持行名为样本
#target_metab_name <- "TMC1.629"  # 指定目标代谢物名称
#metab_data <- as.data.frame(metab_raw[, target_metab_name, drop=FALSE])  # 保持数据框结构

#### 2. 基尼系数筛选（保持不变）
### 修正后的筛选逻辑 ###
calculate_gini <- function(data) {
  apply(data, 2, function(x) {
    reldist::gini(na.omit(x))
  })
}

# 筛选12300个高基尼基因（无需筛选代谢物）
gene_gini <- calculate_gini(gene_data)
top_genes <- names(sort(gene_gini, decreasing = TRUE))[1:12300]
gene_filtered <- gene_data[, top_genes]

### 3. 所有代谢物的随机森林分析（修改部分）#############################
# 并行计算设置
registerDoParallel(cores = 8)  # 根据CPU核心数调整

# 创建存储所有结果的列表
all_results <- list()

# 并行随机森林
# 遍历所有筛选后的代谢物
for (metab_name in colnames(metab_data)) {
  # 准备数据
  target_metab <- metab_data[, metab_name, drop = TRUE]  # 正确提取向量
  analysis_data <- data.frame(target_metab, gene_filtered)

# 训练模型
set.seed(42)
rf_model <- foreach(
  ntree = rep(1250, 8), 
  .combine = randomForest::combine,
  .multicombine = TRUE,
  .packages = "randomForest"  #显式传递包
  ) %dopar% {
  randomForest(
    target_metab ~ .,
    data = analysis_data,
    ntree = ntree,
    importance = TRUE,
    keep.forest = TRUE
  )
}

# 提取重要性
importance_scores <- importance(rf_model, type = 2)
importance_df <- data.frame(
  Gene = rownames(importance_scores),
  Importance = importance_scores[, "IncNodePurity"],
  Metab = metab_name
) %>% 
  arrange(desc(Importance)) %>%
  mutate(Rank = 1:nrow(.))

  all_results[[metab_name]] <- importance_df
}

# 合并所有结果
importance_all_metab <- do.call(rbind, all_results)

### 4. 全组合基尼相关系数计算（新增部分）###############################
gini_correlation <- function(x, y) {
  n <- length(x)
  rank_x <- rank(x) / n
  rank_y <- rank(y) / n
  cov_xy <- cov(rank_x, y) + cov(rank_y, x)
  gmd_x <- 2 * cov(x, rank_x)
  gmd_y <- 2 * cov(y, rank_y)
  gini_corr <- cov_xy / (gmd_x + gmd_y)
  return(gini_corr)
}

# 初始化所有矩阵
gene_metab_gini <- matrix(
  NA, nrow = ncol(gene_data), ncol = ncol(metab_data),
  dimnames = list(colnames(gene_data), colnames(metab_data))
)

# 填充基因-代谢物矩阵
for (i in 1:ncol(gene_data)) {
  for (j in 1:ncol(metab_data)) {
    gene_metab_gini[i, j] <- gini_correlation(gene_data[, i], metab_data[, j])
  }
}

### 5. 生成相关系数排名（新增部分）##################################

### 修改后的 generate_rankings 函数
generate_rankings <- function(matrix, name1, name2) {
  # 将矩阵转换为数据框并强制转换为字符
  df <- reshape2::melt(matrix) %>%
    mutate(
      Var1 = as.character(Var1),
      Var2 = as.character(Var2)
    )
  colnames(df) <- c(name1, name2, "Gini_Correlation")
  
  # 筛选非自身比较项
  df <- df[df[[name1]] != df[[name2]], ]
  
  # 按绝对值排序
  df %>%
    mutate(Abs_Correlation = abs(Gini_Correlation)) %>%
    arrange(desc(Abs_Correlation)) %>%
    select(-Abs_Correlation)
}

# 生成各类型排名
gene_metab_rank <- generate_rankings(gene_metab_gini, "Gene", "Metab")

#save importance_df
write.table(importance_all_metab, file=paste0(opt$outdir,"/",opt$prefix,"_importance.txt"), sep = '\t', quote = F, row.names = F)
write.table(gene_metab_rank, file=paste0(opt$outdir,"/",opt$prefix,"_GINI_rank.txt"), sep = '\t', quote = F, row.names = F)
