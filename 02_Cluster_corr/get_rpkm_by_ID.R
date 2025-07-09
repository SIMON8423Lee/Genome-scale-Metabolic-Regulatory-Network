#!/usr/bin/Rscript
library('getopt');
spec = matrix(c(
                                'help' , 'h', 0, "logical","get help",
                                'Expression_data' , 'e', 1, "character","the expression data, required",
                                'geneID' , 'g', 1, "character","gene ID, required",
                                'outdir' , 'o', 1, "character","the output file directory [optional, default: cwd ]"
                ), byrow=TRUE, ncol=5);
opt = getopt(spec);

# define usage function
print_usage <- function(spec=NULL){
        cat(getopt(spec, usage=TRUE));
        cat("Usage example: \n")
        cat("
        Rscript get_rpkm_by_ID.R -e Expression_data.txt -g geneID.txt -o ./
                                        \n")
        q(status=1);
}
# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) { print_usage(spec) }
if ( is.null(opt$Expression_data) ) { print_usage(spec) }
if ( is.null(opt$geneID) ) { print_usage(spec) }
if ( is.null(opt$outdir) )      { opt$outdir = getwd() }

if( !file.exists(opt$outdir) ){
        if( !dir.create(opt$outdir, showWarnings = FALSE, recursive = TRUE) ){
                stop(paste("dir.create failed: output dir=",opt$outdir,sep=""))
        }
}

#load data
RPKM <- data.frame(read.table(opt$Expression_data, header=1, sep = '\t'))
#Set the first column as index
rownames(RPKM) <- RPKM$geneID
#load ID
ID <- data.frame(read.table(opt$geneID, header=1, sep = '\t'))
#set ID as vector
ID <- as.vector(ID)
#set the first column as index
ID <- ID$geneID
#get rpkm by ID
rpkm <- RPKM[RPKM$geneID %in% ID,]
write.table(rpkm,file = paste0(opt$outdir, "/rpkm.txt"), sep = "\t", row.names = F, quote = F)
