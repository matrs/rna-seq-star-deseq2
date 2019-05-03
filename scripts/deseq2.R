log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library("DESeq2")

parallel <- FALSE
paste(list("snakemake@threads:", snakemake@threads))
if (snakemake@threads > 1) {
    library("BiocParallel")
    # setup parallelization
    register(MulticoreParam(snakemake@threads))
    parallel <- TRUE
}

dds <- readRDS(snakemake@input[[1]])

#mine
paste(list("snakemake@params str(): ", str(snakemake@params)), sep="\n")

contrast <- c("condition", snakemake@params[["contrast"]])
# mine
paste("This is the contrast", contrast, sep=" || ")
res <- results(dds, contrast=contrast, parallel=parallel)
print("res")
print(res)
# shrink fold changes for lowly expressed genes
res <- lfcShrink(dds, contrast=contrast, res=res)
print("res shrinked")
print(res)
# sort by p-value
res <- res[order(res$padj),]
print("res with ordered $padj")
print(res)
# TODO explore IHW usage
print('snakemake@output[["table"]]')
print(snakemake@output[["table"]])
# store results
svg(snakemake@output[["ma_plot"]])
plotMA(res, ylim=c(-2,2))
dev.off()

write.table(as.data.frame(res), file=snakemake@output[["table"]])
