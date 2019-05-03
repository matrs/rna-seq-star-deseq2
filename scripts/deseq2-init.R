#Logging R scripts
log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library("DESeq2")

parallel <- FALSE
if (snakemake@threads > 1) {
    library("BiocParallel")
    # setup parallelization
    register(MulticoreParam(snakemake@threads))
    parallel <- TRUE
}
print("snakemake@input")
print(snakemake@input)
# colData and countData must have the same sample order, but this is ensured
# by the way we create the count matrix
cts <- read.table(snakemake@input[["counts"]], header=TRUE, row.names="gene", check.names=FALSE)
# mine: Here better to paste str, because paste head() will format
# everything as character.
paste(list("snakemake@input str()", str(snakemake@input)), sep="\n")
paste(list("snakemake@output ", snakemake@output), sep="\n")
paste(list("typeof() and head of `cts`",typeof(cts)), sep="\n")
print(head(cts))


coldata <- read.table(snakemake@params[["samples"]], header=TRUE, row.names="sample", check.names=FALSE)
print("coldata")
#data sample information, `head()` isn't needed
print(coldata)

dds <- DESeqDataSetFromMatrix(countData=cts,
                              colData=coldata,
                              design=~ condition)
print('snakemake@params[["samples"]]')
print(snakemake@params[["samples"]])
print("dds")
print(dds)
# remove uninformative columns
dds <- dds[ rowSums(counts(dds)) > 1, ]
# normalization and preprocessing
dds <- DESeq(dds, parallel=parallel)

saveRDS(dds, file=snakemake@output[[1]])
