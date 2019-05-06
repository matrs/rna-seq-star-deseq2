############################################################################
# All of this is when i want to run this snakefile as snatndalone, not a part of the whole pipeline
# which already includes it.
#import pandas as pd
#from snakemake.utils import validate, min_version
#from glob import glob
#
#configfile: "config.yaml"
#validate(config, schema="schemas/config.schema.yaml")

#samples = pd.read_table(config["samples"]).set_index("sample", drop=False)
#print(samples["sample"])
#samples.to_csv("pandas_table.tsv", sep="\t")

#validate(samples, schema="schemas/samples.schema.yaml")

#units = pd.read_table(config["units"], dtype=str).set_index(["sample", "unit"], drop=False)
#units.index = units.index.set_levels([i.astype(str) for i in units.index.levels])  # enforce str in index
#validate(units, schema="schemas/units.schema.yaml")
#print("printing samples and units:", samples, units, sep="|||\n|||", end="\n\n")
#####################################################################################

#bbduk.sh in={} out=Qclean_{/} ref=$Adapters \
#ktrim=r k=23 mink=11 hdist=1 tpe tbo qtrim=rl trimq=25 minlen=60 int=t ow=t 2> 
#BB_summary_{/..}.txt
#bbduk.sh in=$fq1 out=tes_bbduk.fq.gz ref=$adapters ktrim=r k=23 mink=11 hdist=1 \
#tpe tbo t=12 stats=lorea.stats
# in=reads.fq out=trimmed.fq ref=adapters.fa ktrim=r k=28 mink=13 hdist=1 tbo tpe

adapters="/rhome/jluis/bigdata/Miniconda3/envs/bif/opt/bbmap-38.22-0/resources/\
adapters.fa"

#samples=glob("../SRP073391/reads/SRR*")
#print("samples: ", samples, sep="\n", end="\n\n")

def get_fastq(wildcards):
    return units.loc[(wildcards.sample, wildcards.unit), ["fq1", "fq2"]].dropna()

#print(get_fastq({snakemake.wildcard}))

print(samples["sample"].tolist(),units["unit"].tolist())

#rule all:
#    input:
#        expand(["trimmed/{unit.sample}-{unit.unit}.1.fastq.gz","trimmed/{unit.sample}-{unit.unit}.2.fastq.gz"], 
#               unit=units.itertuples())
    
rule bbduk_trim_pe:
    input:
        get_fastq
    output:
        fastq1="trimmed/{sample}-{unit}.1.fastq.gz",
        fastq2="trimmed/{sample}-{unit}.2.fastq.gz",
        #stats="log/bbduk/{sample}-{unit}.stats"
        stats="trimmed/{sample}-{unit}.qc.txt"
    params:
        ref= adapters,
        extra="tpe tbo",
        memory="-Xmx5g"
    log:
        "logs/bbduk/{sample}-{unit}.log" 
    #Aparently pigz causes crashes - related to threads, better to disable it
    threads:
        4
    shell:
        "bbduk.sh {params.memory} {input} out1={output.fastq1} out2={output.fastq2} ref={params.ref} "
        "stats={output.stats} ktrim=r k=23 mink=11 hdist=1 {params.extra} t={threads} --overwrite pigz=f unpigz=f 2> {log}"
