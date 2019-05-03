from pprint import pprint
import pandas as pd
import sys

#Logging python scripts
sys.stdout = open(snakemake.log[0], 'w')

print("snakemake.input: ", snakemake.input)
print("snakemake.output: ",snakemake.output)
print("snakemake.log, snakemake.log[0] and their types: ",snakemake.log,snakemake.log[0], type(snakemake.log), type(snakemake.log[0]))

counts = [pd.read_table(f, index_col=0, usecols=[0, 2], header=None, skiprows=4)
          for f in snakemake.input]
print("length of `counts` list and head of its two 1st elements: ", len(counts), counts[0].head(),
      counts[1].head(), sep="\n\n")

for t, sample in zip(counts, snakemake.params.samples):
    t.columns = [sample]

print("print t and sample variables: ", t.head(), sample, sep="\n\n")

matrix = pd.concat(counts, axis=1)
print("matrix type, shape, head and summary",type(matrix), matrix.shape, matrix.head(), matrix.describe(), sep="\n\n")
matrix.to_csv("matrix_concat.tsv", sep="\t")

matrix.index.name = "gene"
# collapse technical replicates
matrix = matrix.groupby(matrix.columns, axis=1).sum()
print("matrix groupby (by columns and `sum()`), shape and summary:", matrix.head(), matrix.shape, matrix.describe(), sep="\n\n")

matrix.to_csv(snakemake.output[0], sep="\t")
