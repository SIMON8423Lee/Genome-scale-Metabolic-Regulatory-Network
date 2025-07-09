#!/usr/bin/Rscript
library('getopt');
spec = matrix(c(
                                'help' , 'h', 0, "logical","get help",
                                'input_data' , 'e', 1, "character","the expression data, required",
                                'outdir' , 'o', 1, "character","the output file directory [optional, default: cwd ]"
                ), byrow=TRUE, ncol=5);
opt = getopt(spec);

# define usage function
print_usage <- function(spec=NULL){
        cat(getopt(spec, usage=TRUE));
        cat("Usage example: \n")
        cat("
        Rscript melt.R -e input_data.txt  -o ./
                                        \n")
        q(status=1);
}
# if help was asked for print a friendly message
# and exit with a non-zero error code
if ( !is.null(opt$help) ) { print_usage(spec) }
if ( is.null(opt$input_data) ) { print_usage(spec) }
if ( is.null(opt$outdir) )      { opt$outdir = getwd() }

if( !file.exists(opt$outdir) ){
        if( !dir.create(opt$outdir, showWarnings = FALSE, recursive = TRUE) ){
                stop(paste("dir.create failed: output dir=",opt$outdir,sep=""))
        }
}
library('reshape2')
#load data
dt <- data.frame(read.table(paste0(opt$input_data,''),header = T,sep = '\t'))
dt1 <- melt(dt)
#write data
write.table(dt1,file = paste0(opt$outdir, "/melt.txt"), sep = "\t", row.names = F, quote = F)
